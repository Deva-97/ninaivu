import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<AdminDashboardStats> getAdminStats();
  Future<AgentDashboardStats> getAgentStats();
}
