import 'package:insurance_reminders/data/datasources/local/dashboard_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/domain/entities/dashboard_stats.dart';
import 'package:insurance_reminders/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    DashboardLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
  }) : _localDataSource = localDataSource ?? DashboardLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource();

  final DashboardLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;

  @override
  Future<AdminDashboardStats> getAdminStats() async {
    final currentUser = await _requireCurrentUser();
    return _localDataSource.getAdminStats(currentUser.businessId);
  }

  @override
  Future<AgentDashboardStats> getAgentStats() async {
    final currentUser = await _requireCurrentUser();
    return _localDataSource.getAgentStats(
      businessId: currentUser.businessId,
      userId: currentUser.id,
    );
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }
}
