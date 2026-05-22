part of 'auth_service.dart';

extension _AuthServiceBootstrap on AuthService {
  Future<void> _checkAuthFromSplash() async {
    await Future.delayed(const Duration(seconds: 1));

    final preferences = await AppPreferences.getInstance();
    final firebaseUser = firebaseAuth?.currentUser;
    if (firebaseUser != null) {
      await checkUserAfterLogin();
      return;
    }

    final restoredLocalUser = await _restoreOfflineSessionIfAvailable(
      preferences,
    );
    if (restoredLocalUser != null) {
      await BackgroundSyncService.instance.ensureRegistered();
      if (restoredLocalUser.profileCompleted) {
        _navigateByRole(restoredLocalUser.role);
      } else {
        Get.offAllNamed(AppRoutes.profileSetup);
      }
      return;
    }

    await preferences.clearSession();
    await BackgroundSyncService.instance.cancelAllTasks();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _checkUserAfterLogin() async {
    final firebaseUser = firebaseAuth?.currentUser;
    final preferences = await AppPreferences.getInstance();
    if (firebaseUser == null) {
      final restoredLocalUser = await _restoreOfflineSessionIfAvailable(
        preferences,
      );
      if (restoredLocalUser != null) {
        await BackgroundSyncService.instance.ensureRegistered();
        if (restoredLocalUser.profileCompleted) {
          _navigateByRole(restoredLocalUser.role);
        } else {
          Get.offAllNamed(AppRoutes.profileSetup);
        }
        return;
      }

      await preferences.clearSession();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final localUser = await userLocalDataSource.getUserById(firebaseUser.uid);

    // A completed local profile is enough to restore the app immediately, which
    // keeps startup fast and allows offline access after the first login.
    if (localUser != null && localUser.profileCompleted) {
      await preferences.saveSession(
        userId: localUser.id,
        role: localUser.role,
        businessId: localUser.businessId,
      );
      await BackgroundSyncService.instance.ensureRegistered();
      _navigateByRole(localUser.role);
      return;
    }

    try {
      // Firestore is used as the authority only when local profile state is
      // missing or incomplete on this device.
      final remoteUser = await userRemoteDataSource.getUserById(
        firebaseUser.uid,
      );
      if (remoteUser != null && remoteUser.profileCompleted) {
        await userLocalDataSource.insertOrUpdateUser(remoteUser);
        await userLocalDataSource.markUserSynced(remoteUser.id);
        await preferences.saveSession(
          userId: remoteUser.id,
          role: remoteUser.role,
          businessId: remoteUser.businessId,
        );
        await BackgroundSyncService.instance.ensureRegistered();
        _navigateByRole(remoteUser.role);
        return;
      }
    } on UserFetchUnavailableException {
      debugPrint(
        'Firestore user lookup is temporarily unavailable for ${firebaseUser.uid}.',
      );

      if (localUser != null) {
        await preferences.saveSession(
          userId: localUser.id,
          role: localUser.role,
          businessId: localUser.businessId,
        );
        await BackgroundSyncService.instance.ensureRegistered();
        Get.offAllNamed(AppRoutes.profileSetup);
        return;
      }

      throw Exception(
        'We could not verify your account right now. '
        'Please check your connection and try again.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore user lookup failed for ${firebaseUser.uid}: ${e.code} ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Unexpected auth lookup error for ${firebaseUser.uid}: $e');
      rethrow;
    }

    Get.offAllNamed(AppRoutes.profileSetup);
  }

  Future<String?> _checkUserAfterLoginError() async {
    try {
      await _checkUserAfterLogin();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed. Please try again.';
    } on FirebaseException catch (e) {
      return e.message ?? 'Unable to reach the server right now.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
