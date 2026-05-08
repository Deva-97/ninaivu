import '../constants/app_enums.dart';

class PermissionHelper {
  static bool canCreateAgent(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewAllClients(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canDeletePolicy(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canAccessGlobalSettings(UserRole role) {
    return role == UserRole.admin;
  }
}
