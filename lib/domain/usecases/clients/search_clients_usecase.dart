import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class SearchClientsUseCase {
  SearchClientsUseCase(this._repository);

  final ClientRepository _repository;

  Future<List<Client>> call(String query) => _repository.searchClients(query);
}
