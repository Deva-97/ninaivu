import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class UpdatePolicyUseCase {
  UpdatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Policy> call(Policy policy) => _repository.updatePolicy(policy);
}
