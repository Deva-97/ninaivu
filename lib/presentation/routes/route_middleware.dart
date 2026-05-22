import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

/// Blocks protected routes when there is no active local or Firebase session.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({int priority = 0}) : _priority = priority;

  final int _priority;
  @override
  int? get priority => _priority;

  final AuthService _authService = AuthService();

  @override
  RouteSettings? redirect(String? route) {
    final preferences = AppPreferences.currentInstance;
    // Middleware accepts either a live Firebase user or a locally restored
    // session because app startup can hydrate preferences before auth checks finish.
    if (_authService.currentUser != null ||
        (preferences?.userId != null && preferences!.userId!.isNotEmpty)) {
      return null;
    }
    return const RouteSettings(name: AppRoutes.login);
  }
}

/// Enforces role-based navigation after the user is authenticated.
class RoleMiddleware extends GetMiddleware {
  RoleMiddleware({required this.allowedRoles, int priority = 1})
    : _priority = priority;

  final List<String> allowedRoles;
  final int _priority;

  @override
  int? get priority => _priority;

  @override
  RouteSettings? redirect(String? route) {
    final preferences = AppPreferences.currentInstance;
    final rawRole = preferences?.role;
    if (rawRole == null || rawRole.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (allowedRoles.contains(rawRole)) {
      return null;
    }

    // Non-admin users are redirected to the highest-level screen they are still
    // allowed to access instead of seeing a dead-end unauthorized route.
    final role = rawRole.toAppRole();
    if (!PermissionHelper.canAccessAdminRoutes(role)) {
      return const RouteSettings(name: AppRoutes.agentDashboard);
    }

    return RouteSettings(
      name: role == AppRole.admin
          ? AppRoutes.adminDashboard
          : AppRoutes.agentDashboard,
    );
  }
}
