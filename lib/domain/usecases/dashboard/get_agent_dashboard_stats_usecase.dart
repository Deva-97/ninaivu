import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';
import 'package:insurance_reminders/domain/repositories/dashboard_repository.dart';

class GetAgentDashboardStatsUseCase {
  GetAgentDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<AgentDashboardStats> call() => _repository.getAgentStats();
}
