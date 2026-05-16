import 'package:insurance_reminders/domain/repositories/client_repository.dart';

class DeleteClientUseCase {
  DeleteClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<void> call(String clientId) => _repository.deleteClient(clientId);
}
