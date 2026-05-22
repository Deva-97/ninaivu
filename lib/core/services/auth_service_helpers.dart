part of 'auth_service.dart';

extension _AuthServiceHelpers on AuthService {
  String _friendlyAuthError(
    FirebaseAuthException e, {
    required String fallback,
  }) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    if (message.contains('billing_not_enabled') ||
        code == 'billing-not-enabled' ||
        code == 'internal-error') {
      if (message.contains('billing_not_enabled')) {
        return 'Phone login is not enabled for this Firebase project yet. '
            'Enable billing in Google Cloud/Firebase for this project, then try again.';
      }
    }

    if (code == 'invalid-phone-number') {
      return 'Enter a valid mobile number with the correct country format.';
    }
    if (code == 'too-many-requests') {
      return 'Too many OTP attempts were made. Please wait a while and try again.';
    }
    if (code == 'session-expired') {
      return 'The OTP session expired. Please request a new OTP.';
    }
    if (code == 'invalid-verification-code') {
      return 'The OTP you entered is incorrect. Please try again.';
    }
    if (code == 'network-request-failed') {
      return 'Network error while contacting Firebase. Please check your connection and try again.';
    }

    return e.message ?? fallback;
  }

  String _errorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return error.toString();
  }

  FirebaseAuth _requireFirebaseAuth({required String action}) {
    final auth = firebaseAuth;
    if (auth != null) {
      return auth;
    }

    throw Exception(
      '$action is unavailable until Firebase finishes initializing. '
      'Offline data already saved on this device is still available.',
    );
  }
}

FirebaseAuth? _safeFirebaseAuthInstance() {
  try {
    return FirebaseAuth.instance;
  } catch (_) {
    return null;
  }
}
