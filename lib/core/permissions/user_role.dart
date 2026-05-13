enum UserRole { admin, agent, subAgent, customer }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.agent:
        return 'agent';
      case UserRole.subAgent:
        return 'sub_agent';
      case UserRole.customer:
        return 'customer';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'agent':
        return UserRole.agent;
      case 'sub_agent':
        return UserRole.subAgent;
      case 'customer':
        return UserRole.customer;
      default:
        return UserRole.agent;
    }
  }
}
