import 'package:get/get.dart';
import 'package:insurance_reminders/data/repositories/dashboard_repository_impl.dart';
import 'package:insurance_reminders/domain/usecases/dashboard/get_admin_dashboard_stats_usecase.dart';
import 'package:insurance_reminders/domain/usecases/dashboard/get_agent_dashboard_stats_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/admin_dashboard_controller.dart';
import 'package:insurance_reminders/presentation/controllers/agent_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    final repository = DashboardRepositoryImpl();
    Get.lazyPut(
      () => AdminDashboardController(
        getAdminDashboardStatsUseCase: GetAdminDashboardStatsUseCase(repository),
      ),
    );
  }
}

class AgentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    final repository = DashboardRepositoryImpl();
    Get.lazyPut(
      () => AgentDashboardController(
        getAgentDashboardStatsUseCase: GetAgentDashboardStatsUseCase(repository),
      ),
    );
  }
}
