import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';
import 'package:insurance_reminders/domain/repositories/dashboard_repository.dart';

class GetAdminDashboardStatsUseCase {
  GetAdminDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<AdminDashboardStats> call() => _repository.getAdminStats();
}
