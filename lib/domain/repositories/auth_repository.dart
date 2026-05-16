import 'package:insurance_reminders/core/services/auth_service.dart';

abstract class AuthRepository {
  Future<void> checkAuthFromSplash();
  Future<void> signInWithGoogle();
  Future<void> sendOtp({required String mobileNumber});
  Future<OtpSendResult> resendOtp({
    required String mobileNumber,
    required int? resendToken,
  });
  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  });
  Future<void> checkUserAfterLogin();
  Future<String?> checkUserAfterLoginError();
  Future<void> completeProfile({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  });
  Future<void> logout();
}
