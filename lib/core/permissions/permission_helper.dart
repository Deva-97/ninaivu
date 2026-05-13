import 'user_role.dart';

class PermissionHelper {
  PermissionHelper._();

  static bool canCreateAgent(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewAllClients(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canDeletePolicy(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canManageOwnClients(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canManageOwnPolicies(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canCreateFollowUp(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canViewReports(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }
}
