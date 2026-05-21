import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/local_data_change_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/datasources/local/client_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/upcoming_client_event.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';
import 'package:uuid/uuid.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({
    ClientLocalDataSource? localDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    UserLocalDataSource? userLocalDataSource,
    SyncService? syncService,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? ClientLocalDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  final ClientLocalDataSource _localDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final SyncService _syncService;
  final Uuid _uuid;

  @override
  Future<List<Client>> getClients({
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();

    if (PermissionHelper.canManageAllClients(role)) {
      return _localDataSource.getClientsForAdmin(
        businessId: currentUser.businessId,
        query: query,
        limit: limit,
        offset: offset,
      );
    }

    return _localDataSource.getClientsForAgent(
      businessId: currentUser.businessId,
      userId: currentUser.id,
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.searchClientsByNameOrMobile(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      query: query,
    );
  }

  @override
  Future<Client?> getClientDetails(String clientId) async {
    final currentUser = await _requireCurrentUser();
    final client = await _localDataSource.getClientById(clientId);
    if (client == null) {
      return null;
    }
    _ensureClientAccess(currentUser, client);
    return client;
  }

  @override
  Future<bool> hasDuplicateMobile({
    required String mobile,
    String? excludingClientId,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.hasDuplicateMobile(
      businessId: currentUser.businessId,
      mobile: mobile,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      excludingClientId: excludingClientId,
    );
  }

  @override
  Future<Client?> findClientByMobile({
    required String mobile,
    String? excludingClientId,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.findClientByMobile(
      businessId: currentUser.businessId,
      mobile: mobile,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      excludingClientId: excludingClientId,
    );
  }

  @override
  Future<List<UpcomingClientEvent>> getUpcomingSpecialDates({
    int withinDays = 30,
  }) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getUpcomingSpecialDates(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      withinDays: withinDays,
    );
  }

  @override
  Future<Client> addClient({
    required String name,
    required String mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? areaCity,
    String? notes,
    String? profileImagePath,
    int? dateOfBirthMs,
    int? specialDateMs,
    String? specialDateLabel,
  }) async {
    final currentUser = await _requireClientManager();
    final now = DateTime.now().millisecondsSinceEpoch;
    final client = ClientModel(
      id: _uuid.v4(),
      businessId: currentUser.businessId,
      name: name,
      mobile: mobile,
      alternateMobile: alternateMobile,
      email: email,
      address: address,
      areaCity: areaCity,
      notes: notes,
      profileImagePath: profileImagePath,
      dateOfBirthMs: dateOfBirthMs,
      specialDateMs: specialDateMs,
      specialDateLabel: specialDateLabel,
      createdBy: currentUser.id,
      agentId: currentUser.role == AppRole.agent.value ? currentUser.id : null,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      syncStatus: 'pending_create',
    );

    await _localDataSource.insertClient(client);
    LocalDataChangeService.notifyChanged();
    await _enqueue(client, 'create', 'pending_create');
    await _syncService.syncPendingDataBestEffort();
    return client;
  }

  @override
  Future<Client> updateClient(Client client) async {
    final currentUser = await _requireClientManager();
    final existing = await _localDataSource.getClientById(client.id);
    if (existing == null) {
      throw Exception('Client not found');
    }

    if (currentUser.role == AppRole.agent.value &&
        existing.createdBy != currentUser.id &&
        existing.agentId != currentUser.id) {
      throw Exception('You can only update your own clients.');
    }

    final updatedClient = ClientModel.fromEntity(client).copyWith(
      businessId: existing.businessId,
      createdBy: existing.createdBy,
      agentId: client.agentId ?? existing.agentId,
      assignedTo: client.assignedTo ?? existing.assignedTo ?? existing.agentId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updateClient(updatedClient);
    LocalDataChangeService.notifyChanged();
    await _enqueue(updatedClient, 'update', 'pending_update');
    await _syncService.syncPendingDataBestEffort();
    return updatedClient;
  }

  @override
  Future<void> deleteClient(String clientId) async {
    final currentUser = await _requireClientManager();
    final existing = await _localDataSource.getClientById(clientId);
    if (existing == null) {
      throw Exception('Client not found');
    }

    if (currentUser.role == AppRole.agent.value &&
        existing.createdBy != currentUser.id &&
        existing.agentId != currentUser.id) {
      throw Exception('You can only delete your own clients.');
    }

    await _localDataSource.softDeleteClient(clientId);
    LocalDataChangeService.notifyChanged();
    final deletedClient = existing.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_delete',
    );
    await _enqueue(deletedClient, 'delete', 'pending_delete');
    await _syncService.syncPendingDataBestEffort();
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }

  Future<AppUserModel> _requireClientManager() async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canManageOwnClients(role)) {
      throw Exception('You do not have permission to manage clients.');
    }
    return currentUser;
  }

  void _ensureClientAccess(AppUserModel currentUser, Client client) {
    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canAccessOwnRecord(
      role: role,
      currentUserId: currentUser.id,
      createdBy: client.createdBy,
      agentId: client.agentId,
      assignedTo: client.assignedTo,
    )) {
      throw Exception('You can only view your own clients.');
    }
  }

  Future<void> _enqueue(
    ClientModel client,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: client.businessId,
        tableName: DatabaseTables.clients,
        recordId: client.id,
        operation: operation,
        payload: client.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }
}
