part of 'auth_service.dart';

extension _AuthServicePhone on AuthService {
  Future<void> _sendOtp({required String mobileNumber}) async {
    final completer = Completer<void>();
    final formattedNumber = _formatIndianPhoneNumber(mobileNumber);
    final auth = _requireFirebaseAuth(action: 'Phone sign-in');

    await auth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await auth.signInWithCredential(credential);
          await _checkUserAfterLogin();
          if (!completer.isCompleted) {
            completer.complete();
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(
                _friendlyAuthError(e, fallback: 'OTP verification failed'),
              ),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(_errorMessage(e)));
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(_friendlyAuthError(e, fallback: 'OTP sending failed')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'mobileNumber': mobileNumber,
            'resendToken': resendToken,
          },
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  Future<OtpSendResult> _resendOtp({
    required String mobileNumber,
    required int? resendToken,
  }) async {
    final completer = Completer<OtpSendResult>();
    final formattedNumber = _formatIndianPhoneNumber(mobileNumber);
    final auth = _requireFirebaseAuth(action: 'OTP resend');

    await auth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await auth.signInWithCredential(credential);
          await _checkUserAfterLogin();
          if (!completer.isCompleted) {
            completer.complete(
              OtpSendResult(verificationId: '', resendToken: resendToken),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(
                _friendlyAuthError(e, fallback: 'OTP verification failed'),
              ),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(_errorMessage(e)));
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(_friendlyAuthError(e, fallback: 'OTP resend failed')),
          );
        }
      },
      codeSent: (String verificationId, int? newResendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            OtpSendResult(
              verificationId: verificationId,
              resendToken: newResendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  Future<void> _verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final auth = _requireFirebaseAuth(action: 'OTP verification');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await auth.signInWithCredential(credential);
      await _checkUserAfterLogin();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e, fallback: 'Invalid OTP'));
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _formatIndianPhoneNumber(String mobileNumber) {
    // Phone auth in this app is India-first, but we still preserve explicitly
    // entered international numbers when the user includes the country prefix.
    final digitsOnly = mobileNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 10) {
      return '+91$digitsOnly';
    }

    if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      return '+$digitsOnly';
    }

    if (mobileNumber.trim().startsWith('+')) {
      return mobileNumber.trim();
    }

    return '+$digitsOnly';
  }
}
