import 'package:get/get.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/domain/entities/dashboard_stats.dart';
import 'package:ninaivu/domain/entities/upcoming_client_event.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_upcoming_special_dates_usecase.dart';
import 'package:ninaivu/domain/usecases/dashboard/get_agent_dashboard_stats_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/export_policies_usecase.dart';
import 'package:ninaivu/presentation/controllers/dashboard_controller.dart';

class AgentDashboardController extends DashboardController<AgentDashboardStats> {
  AgentDashboardController({
    required ExportClientsUseCase exportClientsUseCase,
    required ExportPoliciesUseCase exportPoliciesUseCase,
    required GetAgentDashboardStatsUseCase getAgentDashboardStatsUseCase,
    required GetUpcomingSpecialDatesUseCase getUpcomingSpecialDatesUseCase,
  }) : _exportClientsUseCase = exportClientsUseCase,
       _exportPoliciesUseCase = exportPoliciesUseCase,
       _getAgentDashboardStatsUseCase = getAgentDashboardStatsUseCase,
       _getUpcomingSpecialDatesUseCase = getUpcomingSpecialDatesUseCase;

  final ExportClientsUseCase _exportClientsUseCase;
  final ExportPoliciesUseCase _exportPoliciesUseCase;
  final GetAgentDashboardStatsUseCase _getAgentDashboardStatsUseCase;
  final GetUpcomingSpecialDatesUseCase _getUpcomingSpecialDatesUseCase;

  final stats = Rxn<AgentDashboardStats>();
  final upcomingEvents = <UpcomingClientEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  @override
  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      stats.value = await _getAgentDashboardStatsUseCase();
      upcomingEvents.assignAll(await _getUpcomingSpecialDatesUseCase(withinDays: 30));
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportClients(ExportFormat format) =>
      _exportClientsUseCase(format: format);

  Future<void> exportPolicies(ExportFormat format) =>
      _exportPoliciesUseCase(format: format);
}
