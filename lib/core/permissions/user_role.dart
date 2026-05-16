enum AppRole { admin, agent, subAgent, customer }

extension AppRoleExtension on AppRole {
  String get value {
    switch (this) {
      case AppRole.admin:
        return 'admin';
      case AppRole.agent:
        return 'agent';
      case AppRole.subAgent:
        return 'sub_agent';
      case AppRole.customer:
        return 'customer';
    }
  }

  String get label {
    switch (this) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.agent:
        return 'Agent';
      case AppRole.subAgent:
        return 'Sub Agent';
      case AppRole.customer:
        return 'Customer';
    }
  }
}

extension AppRoleParsing on String {
  AppRole toAppRole() {
    switch (trim().toLowerCase()) {
      case 'admin':
        return AppRole.admin;
      case 'agent':
        return AppRole.agent;
      case 'sub_agent':
      case 'subagent':
        return AppRole.subAgent;
      case 'customer':
        return AppRole.customer;
      default:
        return AppRole.agent;
    }
  }
}
