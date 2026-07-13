part of 'auth_service.dart';

extension _AuthServiceGoogle on AuthService {
  Future<void> _signInWithGoogle() async {
    try {
      final auth = _requireFirebaseAuth(action: 'Google sign-in');
      await _ensureGoogleSignInInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google sign-in did not return an ID token');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await auth.signInWithCredential(credential);
      await _checkUserAfterLogin();
    } on GoogleSignInException catch (e) {
      throw Exception(e.description ?? 'Google login failed');
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e, fallback: 'Google login failed'));
    } catch (e) {
      final message = _errorMessage(e);
      if (_looksLikeGoogleReauthIssue(message)) {
        try {
          final auth = _requireFirebaseAuth(action: 'Google sign-in');
          await _ensureGoogleSignInInitialized();
          await GoogleSignIn.instance.signOut();
          final googleUser = await GoogleSignIn.instance.authenticate();
          final googleAuth = googleUser.authentication;
          final idToken = googleAuth.idToken;

          if (idToken == null || idToken.isEmpty) {
            throw Exception('Google sign-in did not return an ID token');
          }

          final credential = GoogleAuthProvider.credential(idToken: idToken);
          await auth.signInWithCredential(credential);
          await _checkUserAfterLogin();
          return;
        } on GoogleSignInException catch (retryError) {
          throw Exception(retryError.description ?? 'Google login failed');
        } on FirebaseAuthException catch (retryError) {
          throw Exception(
            _friendlyAuthError(retryError, fallback: 'Google login failed'),
          );
        } catch (retryError) {
          throw Exception(_errorMessage(retryError));
        }
      }

      throw Exception(message);
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    final initialization = AuthService._googleSignInInitialization ??=
        GoogleSignIn.instance.initialize(
          serverClientId: defaultTargetPlatform == TargetPlatform.android
              ? null
              : AuthService._googleServerClientId,
        );
    return initialization;
  }

  bool _looksLikeGoogleReauthIssue(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('sign_in_failed') ||
        normalized.contains('user did not grant permission') ||
        normalized.contains('failed to recover auth') ||
        normalized.contains('canceled') ||
        normalized.contains('cancelled');
  }
}
