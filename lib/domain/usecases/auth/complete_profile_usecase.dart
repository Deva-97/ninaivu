import 'package:ninaivu/domain/repositories/auth_repository.dart';

class CompleteProfileUseCase {
  CompleteProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  }) => _repository.completeProfile(
    name: name,
    mobile: mobile,
    email: email,
    inviteCode: inviteCode,
  );
}
