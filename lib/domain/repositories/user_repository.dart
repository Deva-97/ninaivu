import 'package:insurance_reminders/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> getUserById(String id);
  Future<List<AppUser>> getUsersByRole(String role, {String? query});
  Future<List<AppUser>> getAgents({String? query});
  Future<List<AppUser>> getCustomers({String? query});
  Future<AppUser> createAgent({
    required String name,
    required String mobile,
    String? email,
  });
  Future<AppUser> createCustomer({
    required String name,
    required String mobile,
    String? email,
    String? agentId,
  });
  Future<AppUser> updateUserStatus({
    required String userId,
    required String status,
  });
  Future<void> softDeleteUser(String userId);
}
