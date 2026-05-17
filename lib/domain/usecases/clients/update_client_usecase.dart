import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class UpdateClientUseCase {
  UpdateClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client> call(Client client) => _repository.updateClient(client);
}
