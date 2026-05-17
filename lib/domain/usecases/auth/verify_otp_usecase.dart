import 'package:ninaivu/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String verificationId,
    required String otp,
  }) => _repository.verifyOtp(verificationId: verificationId, otp: otp);
}
