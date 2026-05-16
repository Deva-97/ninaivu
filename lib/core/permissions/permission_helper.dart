import 'user_role.dart';

class PermissionHelper {
  PermissionHelper._();

  static bool canManageUsers(AppRole role) => role == AppRole.admin;

  static bool canManageAllClients(AppRole role) => role == AppRole.admin;

  static bool canManageOwnClients(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canManagePolicies(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canManageFollowUps(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canManageReminders(AppRole role) =>
      role == AppRole.admin || role == AppRole.agent;

  static bool canDeletePolicy(AppRole role) => role == AppRole.admin;

  static bool canViewGlobalDashboard(AppRole role) => role == AppRole.admin;

  static bool canAccessSettings(AppRole role) => role == AppRole.admin;

  static bool canAccessAdminRoutes(AppRole role) => role == AppRole.admin;

  static bool canAccessOwnRecord({
    required AppRole role,
    required String currentUserId,
    String? createdBy,
    String? agentId,
    String? assignedTo,
  }) {
    if (role == AppRole.admin) {
      return true;
    }

    return createdBy == currentUserId ||
        agentId == currentUserId ||
        assignedTo == currentUserId;
  }
}
