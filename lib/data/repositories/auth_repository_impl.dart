import 'package:insurance_reminders/core/services/auth_service.dart';
import 'package:insurance_reminders/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Future<void> checkAuthFromSplash() => _authService.checkAuthFromSplash();

  @override
  Future<void> signInWithGoogle() => _authService.signInWithGoogle();

  @override
  Future<void> sendOtp({required String mobileNumber}) =>
      _authService.sendOtp(mobileNumber: mobileNumber);

  @override
  Future<OtpSendResult> resendOtp({
    required String mobileNumber,
    required int? resendToken,
  }) => _authService.resendOtp(
    mobileNumber: mobileNumber,
    resendToken: resendToken,
  );

  @override
  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) => _authService.verifyOtp(verificationId: verificationId, otp: otp);

  @override
  Future<void> checkUserAfterLogin() => _authService.checkUserAfterLogin();

  @override
  Future<String?> checkUserAfterLoginError() =>
      _authService.checkUserAfterLoginError();

  @override
  Future<void> completeProfile({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  }) => _authService.completeProfile(
    name: name,
    mobile: mobile,
    email: email,
    inviteCode: inviteCode,
  );

  @override
  Future<void> logout() => _authService.logout();
}
