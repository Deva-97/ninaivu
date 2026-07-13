import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class FindClientByMobileUseCase {
  FindClientByMobileUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client?> call({required String mobile, String? excludingClientId}) {
    return _repository.findClientByMobile(
      mobile: mobile,
      excludingClientId: excludingClientId,
    );
  }
}
