import 'package:get/get.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/domain/entities/dashboard_stats.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/dashboard/get_admin_dashboard_stats_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/export_policies_usecase.dart';
import 'package:ninaivu/presentation/controllers/dashboard_controller.dart';

class AdminDashboardController extends DashboardController<AdminDashboardStats> {
  AdminDashboardController({
    required ExportClientsUseCase exportClientsUseCase,
    required ExportPoliciesUseCase exportPoliciesUseCase,
    required GetAdminDashboardStatsUseCase getAdminDashboardStatsUseCase,
  }) : _exportClientsUseCase = exportClientsUseCase,
       _exportPoliciesUseCase = exportPoliciesUseCase,
       _getAdminDashboardStatsUseCase = getAdminDashboardStatsUseCase;

  final ExportClientsUseCase _exportClientsUseCase;
  final ExportPoliciesUseCase _exportPoliciesUseCase;
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

  Future<void> exportClients(ExportFormat format) =>
      _exportClientsUseCase(format: format);

  Future<void> exportPolicies(ExportFormat format) =>
      _exportPoliciesUseCase(format: format);
}
