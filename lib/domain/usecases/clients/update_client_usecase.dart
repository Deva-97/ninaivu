import 'package:insurance_reminders/domain/entities/client.dart';
import 'package:insurance_reminders/domain/repositories/client_repository.dart';

class UpdateClientUseCase {
  UpdateClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client> call(Client client) => _repository.updateClient(client);
}
