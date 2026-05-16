import 'package:get/get.dart';
import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';
import 'package:insurance_reminders/domain/usecases/dashboard/get_admin_dashboard_stats_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/dashboard_controller.dart';

class AdminDashboardController extends DashboardController<AdminDashboardStats> {
  AdminDashboardController({
    required GetAdminDashboardStatsUseCase getAdminDashboardStatsUseCase,
  }) : _getAdminDashboardStatsUseCase = getAdminDashboardStatsUseCase;

  final GetAdminDashboardStatsUseCase _getAdminDashboardStatsUseCase;

  final stats = Rxn<AdminDashboardStats>();

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
      stats.value = await _getAdminDashboardStatsUseCase();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
