import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.priority = 0});

  @override
  final int priority;

  final AuthService _authService = AuthService();

  @override
  RouteSettings? redirect(String? route) {
    // TODO(dev): Move this check behind an auth use case/repository once
    // navigation bindings are introduced.
    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  RoleMiddleware({
    required this.allowedRoles,
    this.priority = 1,
  });

  final List<String> allowedRoles;

  @override
  final int priority;

  @override
  RouteSettings? redirect(String? route) {
    // TODO(dev): Resolve the local user role from the repository/usecase layer
    // and redirect to the right dashboard when protected modules are added.
    return null;
  }
}
