import 'package:ninaivu/domain/entities/policy.dart';

abstract class PolicyRepository {
  Future<List<Policy>> getPolicies({
    String? query,
    int limit = 50,
    int offset = 0,
  });
  Future<List<Policy>> getPoliciesByClient(String clientId);
  Future<List<Policy>> getExpiringPolicies({int withinDays = 30});
  Future<List<Policy>> getExpiredPolicies();
  Future<List<Policy>> searchPolicies({
    required String query,
    String? clientId,
  });
  Future<Policy?> getPolicyById(String policyId);
  Future<void> updateRenewalStatus({
    required String policyId,
    required String renewalStatus,
  });
  Future<Policy> addPolicy(Policy policy);
  Future<Policy> updatePolicy(Policy policy);
  Future<void> deletePolicy(String policyId);
}
