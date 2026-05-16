class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalAgents,
    required this.totalCustomers,
    required this.totalClients,
    required this.totalPolicies,
    required this.renewalsToday,
    required this.upcoming7Days,
    required this.expiredPolicies,
    required this.pendingFollowUps,
    required this.missedFollowUps,
  });

  final int totalAgents;
  final int totalCustomers;
  final int totalClients;
  final int totalPolicies;
  final int renewalsToday;
  final int upcoming7Days;
  final int expiredPolicies;
  final int pendingFollowUps;
  final int missedFollowUps;
}

class AgentDashboardStats {
  const AgentDashboardStats({
    required this.myClients,
    required this.myPolicies,
    required this.renewalsToday,
    required this.upcoming7Days,
    required this.upcoming30Days,
    required this.followUpsToday,
    required this.missedFollowUps,
  });

  final int myClients;
  final int myPolicies;
  final int renewalsToday;
  final int upcoming7Days;
  final int upcoming30Days;
  final int followUpsToday;
  final int missedFollowUps;
}
