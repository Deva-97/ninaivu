import 'package:insurance_reminders/domain/entities/client.dart';
import 'package:insurance_reminders/domain/repositories/client_repository.dart';

class GetClientDetailsUseCase {
  GetClientDetailsUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client?> call(String clientId) => _repository.getClientDetails(clientId);
}
