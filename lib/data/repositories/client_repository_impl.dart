import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/data/datasources/local/client_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/data/models/client_model.dart';
import 'package:insurance_reminders/domain/entities/client.dart';
import 'package:insurance_reminders/domain/repositories/client_repository.dart';
import 'package:uuid/uuid.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({
    ClientLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? ClientLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _uuid = uuid ?? const Uuid();

  final ClientLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
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
  Future<Client?> getClientDetails(String clientId) =>
      _localDataSource.getClientById(clientId);

  @override
  Future<Client> addClient({
    required String name,
    required String mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? areaCity,
    String? notes,
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
      createdBy: currentUser.id,
      agentId: currentUser.role == AppRole.agent.value ? currentUser.id : null,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      syncStatus: 'pending_create',
    );

    await _localDataSource.insertClient(client);
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
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updateClient(updatedClient);
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
}
