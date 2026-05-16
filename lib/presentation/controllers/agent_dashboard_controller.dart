import 'package:get/get.dart';
import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';
import 'package:insurance_reminders/domain/usecases/dashboard/get_agent_dashboard_stats_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/dashboard_controller.dart';

class AgentDashboardController extends DashboardController<AgentDashboardStats> {
  AgentDashboardController({
    required GetAgentDashboardStatsUseCase getAgentDashboardStatsUseCase,
  }) : _getAgentDashboardStatsUseCase = getAgentDashboardStatsUseCase;

  final GetAgentDashboardStatsUseCase _getAgentDashboardStatsUseCase;

  final stats = Rxn<AgentDashboardStats>();

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
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
