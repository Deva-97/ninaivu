part of 'auth_service.dart';

extension _AuthServiceSession on AuthService {
  Future<void> _logout() async {
    await firebaseAuth?.signOut();
    await GoogleSignIn.instance.signOut();
    final preferences = await AppPreferences.getInstance();
    await preferences.clearSession();
    await BackgroundSyncService.instance.cancelAllTasks();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<AppUserModel?> _restoreOfflineSessionIfAvailable(
    AppPreferences preferences,
  ) async {
    final userId = preferences.userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final localUser = await userLocalDataSource.getUserById(userId);
    if (localUser == null || localUser.isDeleted) {
      return null;
    }

    await preferences.saveSession(
      userId: localUser.id,
      role: localUser.role,
      businessId: localUser.businessId,
    );
    return localUser;
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'agent':
        Get.offAllNamed(AppRoutes.agentDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }
}
