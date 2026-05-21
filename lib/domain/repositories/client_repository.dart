import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/upcoming_client_event.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients({
    String? query,
    int limit = 50,
    int offset = 0,
  });
  Future<List<Client>> searchClients(String query);
  Future<Client?> getClientDetails(String clientId);
  Future<Client?> findClientByMobile({
    required String mobile,
    String? excludingClientId,
  });
  Future<bool> hasDuplicateMobile({
    required String mobile,
    String? excludingClientId,
  });
  Future<List<UpcomingClientEvent>> getUpcomingSpecialDates({int withinDays = 30});
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
  });
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}
