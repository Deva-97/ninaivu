import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class GetPolicyByIdUseCase {
  GetPolicyByIdUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Policy?> call(String policyId) => _repository.getPolicyById(policyId);
}
