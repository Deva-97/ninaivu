import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';
import 'package:insurance_reminders/core/services/app_preferences.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({int priority = 0}) : _priority = priority;

  final int _priority;
  @override
  int? get priority => _priority;

  final AuthService _authService = AuthService();

  @override
  RouteSettings? redirect(String? route) {
    final preferences = AppPreferences.currentInstance;
    if (_authService.currentUser != null ||
        (preferences?.userId != null && preferences!.userId!.isNotEmpty)) {
      return null;
    }
    return const RouteSettings(name: AppRoutes.login);
  }
}

class RoleMiddleware extends GetMiddleware {
  RoleMiddleware({
    required this.allowedRoles,
    int priority = 1,
  }) : _priority = priority;

  final List<String> allowedRoles;
  final AuthService _authService = AuthService();
  final int _priority;

  @override
  int? get priority => _priority;

  @override
  RouteSettings? redirect(String? route) {
    final preferences = AppPreferences.currentInstance;
    final rawRole = preferences?.role;
    if (_authService.currentUser == null || rawRole == null || rawRole.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (allowedRoles.contains(rawRole)) {
      return null;
    }

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
