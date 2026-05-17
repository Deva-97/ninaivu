import 'package:ninaivu/domain/entities/dashboard_stats.dart';
import 'package:ninaivu/domain/repositories/dashboard_repository.dart';

class GetAgentDashboardStatsUseCase {
  GetAgentDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<AgentDashboardStats> call() => _repository.getAgentStats();
}
