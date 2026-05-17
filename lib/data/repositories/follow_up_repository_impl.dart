import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/local_data_change_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/datasources/local/follow_up_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/follow_up_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/repositories/follow_up_repository.dart';
import 'package:uuid/uuid.dart';

class FollowUpRepositoryImpl implements FollowUpRepository {
  FollowUpRepositoryImpl({
    FollowUpLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    SyncService? syncService,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? FollowUpLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  final FollowUpLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final SyncService _syncService;
  final Uuid _uuid;

  @override
  Future<FollowUp> addFollowUp(FollowUp followUp) async {
    final currentUser = await _requireCurrentUser();
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = FollowUpModel.fromEntity(followUp).copyWith(
      id: followUp.id.isEmpty ? _uuid.v4() : followUp.id,
      businessId: currentUser.businessId,
      createdBy: followUp.createdBy.isEmpty ? currentUser.id : followUp.createdBy,
      agentId:
          followUp.agentId ??
          (currentUser.role == AppRole.agent.value ? currentUser.id : null),
      assignedTo:
          followUp.assignedTo ??
          followUp.agentId ??
          (currentUser.role == AppRole.agent.value ? currentUser.id : currentUser.id),
      createdAt: followUp.createdAt == 0 ? now : followUp.createdAt,
      updatedAt: now,
      syncStatus: 'pending_create',
    );
    await _localDataSource.insertFollowUp(model);
    LocalDataChangeService.notifyChanged();
    await _enqueue(model, 'create', 'pending_create');
    await _syncService.syncPendingData();
    return model;
  }

  @override
  Future<FollowUp> updateFollowUp(FollowUp followUp) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUp.id);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);

    final model = FollowUpModel.fromEntity(followUp).copyWith(
      businessId: existing.businessId,
      createdBy: existing.createdBy,
      createdAt: existing.createdAt,
      agentId: followUp.agentId ?? existing.agentId,
      assignedTo: followUp.assignedTo ?? existing.assignedTo ?? existing.agentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updateFollowUp(model);
    LocalDataChangeService.notifyChanged();
    await _enqueue(model, 'update', 'pending_update');
    await _syncService.syncPendingData();
    return model;
  }

  @override
  Future<void> deleteFollowUp(String followUpId) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUpId);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);
    await _localDataSource.softDeleteFollowUp(followUpId);
    LocalDataChangeService.notifyChanged();
    final deleted = existing.copyWith(
      isDeleted: true,
      status: 'Cancelled',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_delete',
    );
    await _enqueue(deleted, 'delete', 'pending_delete');
    await _syncService.syncPendingData();
  }

  @override
  Future<void> markFollowUpCompleted(String followUpId) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUpId);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);
    await _localDataSource.markFollowUpCompleted(followUpId);
    LocalDataChangeService.notifyChanged();
    final updated = existing.copyWith(
      status: 'Completed',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _enqueue(updated, 'update', 'pending_update');
    await _syncService.syncPendingData();
  }

  @override
  Future<List<FollowUp>> getTodayFollowUps() => getFollowUps(filter: 'today');

  @override
  Future<List<FollowUp>> getMissedFollowUps() => getFollowUps(filter: 'missed');

  @override
  Future<List<FollowUp>> getUpcomingFollowUps({int withinDays = 30}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getFollowUps(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      filter: 'upcoming',
      withinDays: withinDays,
    );
  }

  @override
  Future<List<FollowUp>> getFollowUps({String filter = 'today'}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getFollowUps(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      filter: filter,
    );
  }

  @override
  Future<FollowUp?> getFollowUpById(String followUpId) async {
    final currentUser = await _requireCurrentUser();
    final followUp = await _localDataSource.getFollowUpById(followUpId);
    if (followUp == null) {
      return null;
    }
    _ensureFollowUpAccess(currentUser, followUp);
    return followUp;
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }

  void _ensureFollowUpAccess(AppUserModel currentUser, FollowUpModel followUp) {
    final role = currentUser.role.toAppRole();
    if (PermissionHelper.canManageAllClients(role)) {
      return;
    }

    final canAccess =
        followUp.createdBy == currentUser.id ||
        followUp.agentId == currentUser.id ||
        followUp.assignedTo == currentUser.id;
    if (!canAccess) {
      throw Exception('You can only manage your own follow-ups.');
    }
  }

  Future<void> _enqueue(
    FollowUpModel followUp,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: followUp.businessId,
        tableName: DatabaseTables.followUps,
        recordId: followUp.id,
        operation: operation,
        payload: followUp.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }
}
