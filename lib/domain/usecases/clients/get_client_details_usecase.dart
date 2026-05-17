import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class GetClientDetailsUseCase {
  GetClientDetailsUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client?> call(String clientId) => _repository.getClientDetails(clientId);
}
