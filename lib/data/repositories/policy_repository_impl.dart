import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/local_data_change_service.dart';
import 'package:ninaivu/core/services/reminder_generator_service.dart';
import 'package:ninaivu/core/services/reminder_scheduler_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/client_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/policy_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/reminder_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/policy_model.dart';
import 'package:ninaivu/data/models/reminder_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';
import 'package:uuid/uuid.dart';

/// Offline-first policy repository.
///
/// Policy changes are persisted locally, reminder side effects are updated, a
/// sync queue entry is created, and then remote sync is attempted opportunistically.
class PolicyRepositoryImpl implements PolicyRepository {
  PolicyRepositoryImpl({
    PolicyLocalDataSource? localDataSource,
    ClientLocalDataSource? clientLocalDataSource,
    UserLocalDataSource? userLocalDataSource,
    ReminderLocalDataSource? reminderLocalDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    ReminderGeneratorService? reminderGeneratorService,
    ReminderSchedulerService? reminderSchedulerService,
    SyncService? syncService,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? PolicyLocalDataSource(),
       _clientLocalDataSource =
           clientLocalDataSource ?? ClientLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _reminderLocalDataSource =
           reminderLocalDataSource ?? ReminderLocalDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _reminderGeneratorService =
           reminderGeneratorService ?? ReminderGeneratorService(),
       _reminderSchedulerService =
           reminderSchedulerService ?? ReminderSchedulerService(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  final PolicyLocalDataSource _localDataSource;
  final ClientLocalDataSource _clientLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final ReminderLocalDataSource _reminderLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final ReminderGeneratorService _reminderGeneratorService;
  final ReminderSchedulerService _reminderSchedulerService;
  final SyncService _syncService;
  final Uuid _uuid;

  @override
  Future<List<Policy>> getPolicies({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    if (PermissionHelper.canManageAllClients(role)) {
      return _localDataSource.getPoliciesForAdmin(
        businessId: currentUser.businessId,
        query: query,
        limit: limit,
        offset: offset,
      );
    }

    return _localDataSource.getPoliciesForAgent(
      businessId: currentUser.businessId,
      userId: currentUser.id,
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Policy>> getPoliciesByClient(String clientId) async {
    final currentUser = await _requireCurrentUser();
    final client = await _clientLocalDataSource.getClientById(clientId);
    if (client == null) {
      return const [];
    }
    _ensurePolicyAccess(
      currentUser,
      createdBy: client.createdBy,
      agentId: client.agentId,
    );
    return _localDataSource.getPoliciesByClient(clientId);
  }

  @override
  Future<List<Policy>> getExpiringPolicies({int withinDays = 30}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getExpiringPolicies(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      withinDays: withinDays,
    );
  }

  @override
  Future<List<Policy>> getExpiredPolicies() async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getExpiredPolicies(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
    );
  }

  @override
  Future<List<Policy>> searchPolicies({
    required String query,
    String? clientId,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.searchPolicies(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      query: query,
      clientId: clientId,
    );
  }

  @override
  Future<Policy?> getPolicyById(String policyId) async {
    final currentUser = await _requireCurrentUser();
    final policy = await _localDataSource.getPolicyById(policyId);
    if (policy == null) {
      return null;
    }
    _ensurePolicyAccess(
      currentUser,
      createdBy: policy.createdBy,
      agentId: policy.agentId,
      assignedTo: policy.assignedTo,
    );
    return policy;
  }

  @override
  Future<Policy> addPolicy(Policy policy) async {
    final currentUser = await _requirePolicyManager();
    final model = PolicyModel.fromEntity(policy).copyWith(
      id: policy.id.isEmpty ? _uuid.v4() : policy.id,
      businessId: currentUser.businessId,
      createdBy: policy.createdBy.isEmpty ? currentUser.id : policy.createdBy,
      agentId:
          policy.agentId ??
          (currentUser.role == AppRole.agent.value ? currentUser.id : null),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_create',
    );
    // Policies own reminder generation, so creation/update always refreshes the
    // reminder set instead of trying to patch individual reminder rows by hand.
    await _localDataSource.insertPolicy(model);
    await _refreshRemindersForPolicy(model);
    LocalDataChangeService.notifyChanged();
    await _enqueue(model, 'create', 'pending_create');
    await _syncService.syncPendingDataBestEffort();
    return model;
  }

  @override
  Future<Policy> updatePolicy(Policy policy) async {
    await _requirePolicyManager();
    final existing = await _localDataSource.getPolicyById(policy.id);
    if (existing == null) {
      throw Exception('Policy not found');
    }

    final model = PolicyModel.fromEntity(policy).copyWith(
      businessId: existing.businessId,
      createdBy: existing.createdBy,
      createdAt: existing.createdAt,
      agentId: policy.agentId ?? existing.agentId,
      assignedTo: policy.assignedTo ?? existing.assignedTo ?? existing.agentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updatePolicy(model);
    await _refreshRemindersForPolicy(model);
    LocalDataChangeService.notifyChanged();
    await _enqueue(model, 'update', 'pending_update');
    await _syncService.syncPendingDataBestEffort();
    return model;
  }

  @override
  Future<void> updateRenewalStatus({
    required String policyId,
    required String renewalStatus,
  }) async {
    final currentUser = await _requirePolicyManager();
    final existing = await _localDataSource.getPolicyById(policyId);
    if (existing == null) {
      throw Exception('Policy not found');
    }
    _ensurePolicyAccess(
      currentUser,
      createdBy: existing.createdBy,
      agentId: existing.agentId,
      assignedTo: existing.assignedTo,
    );

    // "Renewed" is the only renewal stage that also changes the canonical
    // policy lifecycle status used by dashboards and reminder generation.
    final nextPolicyStatus = renewalStatus == 'Renewed' ? 'Renewed' : null;
    await _localDataSource.updateRenewalStatus(
      policyId: policyId,
      renewalStatus: renewalStatus,
      policyStatus: nextPolicyStatus,
    );
    final updatedModel = existing.copyWith(
      renewalStatus: renewalStatus,
      status: nextPolicyStatus ?? existing.status,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    LocalDataChangeService.notifyChanged();
    await _enqueue(updatedModel, 'update', 'pending_update');
    await _syncService.syncPendingDataBestEffort();
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    final currentUser = await _requirePolicyManager();
    final existing = await _localDataSource.getPolicyById(policyId);
    if (existing == null) {
      throw Exception('Policy not found');
    }

    if (currentUser.role == AppRole.agent.value &&
        existing.createdBy != currentUser.id &&
        existing.agentId != currentUser.id) {
      throw Exception('You can only delete your own policies.');
    }

    await _cancelAndSoftDeleteReminders(existing.id);
    await _localDataSource.softDeletePolicy(policyId);
    LocalDataChangeService.notifyChanged();
    final deletedModel = existing.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_delete',
    );
    await _enqueue(deletedModel, 'delete', 'pending_delete');
    await _syncService.syncPendingDataBestEffort();
  }

  Future<void> _enqueue(
    PolicyModel policy,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: policy.businessId,
        tableName: DatabaseTables.policies,
        recordId: policy.id,
        operation: operation,
        payload: policy.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }

  Future<AppUserModel> _requirePolicyManager() async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canManagePolicies(role)) {
      throw Exception('You do not have permission to manage policies.');
    }
    return currentUser;
  }

  Future<void> _refreshRemindersForPolicy(PolicyModel policy) async {
    await _cancelAndSoftDeleteReminders(policy.id);

    final reminders = _reminderGeneratorService.generateForPolicy(policy);
    await _reminderLocalDataSource.insertReminders(reminders);
    for (final reminder in reminders) {
      await _enqueueReminder(reminder, 'create', 'pending_create');
    }

    final client = await _clientLocalDataSource.getClientById(policy.clientId);
    await _reminderSchedulerService.scheduleReminders(
      reminders: reminders.where((item) => item.status != 'missed').toList(),
      clientName: client?.name ?? 'Client',
      policyNumber: policy.policyNumber,
      companyName: policy.companyName,
    );
  }

  Future<void> _cancelAndSoftDeleteReminders(String policyId) async {
    final existingReminders = await _reminderLocalDataSource
        .getRemindersByPolicy(policyId);
    if (existingReminders.isNotEmpty) {
      // Old reminders are soft-deleted and queued for sync so devices and
      // Firestore stay consistent after policy date changes.
      await _reminderSchedulerService.cancelReminders(existingReminders);
      await _reminderLocalDataSource.softDeleteByPolicy(policyId);
      for (final reminder in existingReminders) {
        final deletedReminder = reminder.copyWith(
          isDeleted: true,
          status: 'cancelled',
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          syncStatus: 'pending_delete',
        );
        await _enqueueReminder(deletedReminder, 'delete', 'pending_delete');
      }
    }
  }

  void _ensurePolicyAccess(
    AppUserModel currentUser, {
    required String createdBy,
    String? agentId,
    String? assignedTo,
  }) {
    // Access checks stay in the repository so use cases and controllers do not
    // duplicate role logic for every policy read/write path.
    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canAccessOwnRecord(
      role: role,
      currentUserId: currentUser.id,
      createdBy: createdBy,
      agentId: agentId,
      assignedTo: assignedTo,
    )) {
      throw Exception('You can only access your own policies.');
    }
  }

  Future<void> _enqueueReminder(
    ReminderModel reminder,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: reminder.businessId,
        tableName: DatabaseTables.reminders,
        recordId: reminder.id,
        operation: operation,
        payload: reminder.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }
}
