import 'package:insurance_reminders/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String mobileNumber}) =>
      _repository.sendOtp(mobileNumber: mobileNumber);
}
