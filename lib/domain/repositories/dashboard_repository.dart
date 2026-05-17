import 'package:ninaivu/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<AdminDashboardStats> getAdminStats();
  Future<AgentDashboardStats> getAgentStats();
}
