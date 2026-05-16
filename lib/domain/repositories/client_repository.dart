import 'package:insurance_reminders/domain/entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients({
    String? query,
    int limit = 50,
    int offset = 0,
  });
  Future<List<Client>> searchClients(String query);
  Future<Client?> getClientDetails(String clientId);
  Future<Client> addClient({
    required String name,
    required String mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? areaCity,
    String? notes,
  });
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}
