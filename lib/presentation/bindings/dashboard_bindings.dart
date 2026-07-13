import 'package:get/get.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';
import 'package:ninaivu/data/repositories/dashboard_repository_impl.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';
import 'package:ninaivu/domain/usecases/clients/get_upcoming_special_dates_usecase.dart';
import 'package:ninaivu/domain/usecases/dashboard/get_admin_dashboard_stats_usecase.dart';
import 'package:ninaivu/domain/usecases/dashboard/get_agent_dashboard_stats_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/export_policies_usecase.dart';
import 'package:ninaivu/presentation/controllers/admin_dashboard_controller.dart';
import 'package:ninaivu/presentation/controllers/agent_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    final repository = DashboardRepositoryImpl();
    final clientRepository = ClientRepositoryImpl();
    final policyRepository = PolicyRepositoryImpl();
    final exportService = ExportService();
    Get.lazyPut(
      () => AdminDashboardController(
        exportClientsUseCase: ExportClientsUseCase(
          clientRepository,
          exportService,
        ),
        exportPoliciesUseCase: ExportPoliciesUseCase(
          policyRepository,
          clientRepository,
          exportService,
        ),
        getAdminDashboardStatsUseCase: GetAdminDashboardStatsUseCase(
          repository,
        ),
        getUpcomingSpecialDatesUseCase: GetUpcomingSpecialDatesUseCase(
          clientRepository,
        ),
      ),
    );
  }
}

class AgentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    final repository = DashboardRepositoryImpl();
    final clientRepository = ClientRepositoryImpl();
    final policyRepository = PolicyRepositoryImpl();
    final exportService = ExportService();
    Get.lazyPut(
      () => AgentDashboardController(
        exportClientsUseCase: ExportClientsUseCase(
          clientRepository,
          exportService,
        ),
        exportPoliciesUseCase: ExportPoliciesUseCase(
          policyRepository,
          clientRepository,
          exportService,
        ),
        getAgentDashboardStatsUseCase: GetAgentDashboardStatsUseCase(
          repository,
        ),
        getUpcomingSpecialDatesUseCase: GetUpcomingSpecialDatesUseCase(
          clientRepository,
        ),
      ),
    );
  }
}
