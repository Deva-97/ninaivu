import 'package:insurance_reminders/core/database/database_tables.dart';
import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/data/datasources/local/policy_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/data/models/policy_model.dart';
import 'package:insurance_reminders/data/models/sync_queue_model.dart';
import 'package:insurance_reminders/domain/entities/policy.dart';
import 'package:insurance_reminders/domain/repositories/policy_repository.dart';
import 'package:uuid/uuid.dart';

class PolicyRepositoryImpl implements PolicyRepository {
  PolicyRepositoryImpl({
    PolicyLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? PolicyLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _uuid = uuid ?? const Uuid();

  final PolicyLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
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
  Future<List<Policy>> getPoliciesByClient(String clientId) =>
      _localDataSource.getPoliciesByClient(clientId);

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
  Future<Policy?> getPolicyById(String policyId) =>
      _localDataSource.getPolicyById(policyId);

  @override
  Future<Policy> addPolicy(Policy policy) async {
    final currentUser = await _requirePolicyManager();
    final model = PolicyModel.fromEntity(policy).copyWith(
      id: policy.id.isEmpty ? _uuid.v4() : policy.id,
      businessId: currentUser.businessId,
      createdBy: policy.createdBy.isEmpty ? currentUser.id : policy.createdBy,
      agentId: policy.agentId ?? (currentUser.role == AppRole.agent.value ? currentUser.id : null),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_create',
    );
    await _localDataSource.insertPolicy(model);
    await _enqueue(model, 'create', 'pending_create');
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
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updatePolicy(model);
    await _enqueue(model, 'update', 'pending_update');
    return model;
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

    await _localDataSource.softDeletePolicy(policyId);
    final deletedModel = existing.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_delete',
    );
    await _enqueue(deletedModel, 'delete', 'pending_delete');
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
}
