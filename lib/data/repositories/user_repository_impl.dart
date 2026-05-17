import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/services/local_data_change_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    UserLocalDataSource? localDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    SyncService? syncService,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? UserLocalDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  final UserLocalDataSource _localDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final SyncService _syncService;
  final Uuid _uuid;

  @override
  Future<AppUser?> getCurrentUser() => _localDataSource.getCurrentUser();

  @override
  Future<AppUser?> getUserById(String id) => _localDataSource.getUserById(id);

  @override
  Future<List<AppUser>> getUsersByRole(String role, {String? query}) =>
      _localDataSource.getUsersByRole(role, query: query);

  @override
  Future<List<AppUser>> getAgents({String? query}) =>
      _localDataSource.getAgents(query: query);

  @override
  Future<List<AppUser>> getCustomers({String? query}) =>
      _localDataSource.getCustomers(query: query);

  @override
  Future<AppUser> createAgent({
    required String name,
    required String mobile,
    String? email,
  }) {
    return _createUser(
      name: name,
      mobile: mobile,
      email: email,
      role: AppRole.agent.value,
    );
  }

  @override
  Future<AppUser> createCustomer({
    required String name,
    required String mobile,
    String? email,
    String? agentId,
  }) {
    return _createUser(
      name: name,
      mobile: mobile,
      email: email,
      role: AppRole.customer.value,
      agentId: agentId,
    );
  }

  @override
  Future<AppUser> updateUserStatus({
    required String userId,
    required String status,
  }) async {
    await _ensureAdmin();
    final existingUser = await _localDataSource.getUserById(userId);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    final updatedUser = existingUser.copyWith(
      status: status,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );

    await _localDataSource.insertOrUpdateUser(updatedUser);
    LocalDataChangeService.notifyChanged();
    await _enqueue(updatedUser, 'update', 'pending_update');
    await _syncService.syncPendingData();
    return updatedUser;
  }

  @override
  Future<void> softDeleteUser(String userId) async {
    await _ensureAdmin();
    final existingUser = await _localDataSource.getUserById(userId);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    final deletedUser = existingUser.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_delete',
    );

    await _localDataSource.insertOrUpdateUser(deletedUser);
    LocalDataChangeService.notifyChanged();
    await _enqueue(deletedUser, 'delete', 'pending_delete');
    await _syncService.syncPendingData();
  }

  Future<AppUser> _createUser({
    required String name,
    required String mobile,
    String? email,
    required String role,
    String? agentId,
  }) async {
    final currentUser = await _ensureAdmin();
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = AppUserModel(
      id: _uuid.v4(),
      businessId: currentUser.businessId,
      name: name,
      mobile: mobile,
      email: email,
      role: role,
      status: 'active',
      profileCompleted: true,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      syncStatus: 'pending_create',
      createdBy: currentUser.id,
      agentId: agentId,
    );

    await _localDataSource.insertOrUpdateUser(user);
    LocalDataChangeService.notifyChanged();
    await _enqueue(user, 'create', 'pending_create');
    await _syncService.syncPendingData();
    return user;
  }

  Future<AppUserModel> _ensureAdmin() async {
    final currentUser = await _localDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }

    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canManageUsers(role)) {
      throw Exception('You do not have permission to manage users.');
    }

    return currentUser;
  }

  Future<void> _enqueue(
    AppUserModel user,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: user.businessId,
        tableName: DatabaseTables.users,
        recordId: user.id,
        operation: operation,
        payload: user.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }
}
