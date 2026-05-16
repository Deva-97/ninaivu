import 'user_role.dart';

class PermissionHelper {
  PermissionHelper._();

  static bool canManageUsers(AppRole role) => role == AppRole.admin;

  static bool canManageAllClients(AppRole role) => role == AppRole.admin;

  static bool canManageOwnClients(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canManagePolicies(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canDeletePolicy(AppRole role) => role == AppRole.admin;

  static bool canViewGlobalDashboard(AppRole role) => role == AppRole.admin;

  static bool canAccessSettings(AppRole role) => role == AppRole.admin;
}
