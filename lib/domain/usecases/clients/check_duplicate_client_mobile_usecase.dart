import 'package:ninaivu/domain/repositories/client_repository.dart';

class CheckDuplicateClientMobileUseCase {
  CheckDuplicateClientMobileUseCase(this._repository);

  final ClientRepository _repository;

  Future<bool> call({
    required String mobile,
    String? excludingClientId,
  }) {
    return _repository.hasDuplicateMobile(
      mobile: mobile,
      excludingClientId: excludingClientId,
    );
  }
}
