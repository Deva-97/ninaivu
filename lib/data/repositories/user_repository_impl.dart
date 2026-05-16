import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/remote/user_remote_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/domain/entities/app_user.dart';
import 'package:insurance_reminders/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    UserLocalDataSource? localDataSource,
    UserRemoteDataSource? remoteDataSource,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? UserLocalDataSource(),
       _remoteDataSource = remoteDataSource ?? UserRemoteDataSource(),
       _uuid = uuid ?? const Uuid();

  final UserLocalDataSource _localDataSource;
  final UserRemoteDataSource _remoteDataSource;
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
    await _tryRemoteUpsert(updatedUser);
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
    await _tryRemoteUpsert(deletedUser);
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
    await _tryRemoteUpsert(user);
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

  Future<void> _tryRemoteUpsert(AppUserModel user) async {
    try {
      await _remoteDataSource.upsertUser(user);
      await _localDataSource.markUserSynced(user.id);
    } catch (_) {
      // Keep SQLite as source of truth for Phase 1 even if Firestore is unavailable.
    }
  }
}
