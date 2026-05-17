import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class GetClientsUseCase {
  GetClientsUseCase(this._repository);

  final ClientRepository _repository;

  Future<List<Client>> call({
    String? query,
    int limit = 50,
    int offset = 0,
  }) => _repository.getClients(query: query, limit: limit, offset: offset);
}
