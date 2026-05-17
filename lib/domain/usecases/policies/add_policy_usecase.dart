import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class AddPolicyUseCase {
  AddPolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Policy> call(Policy policy) => _repository.addPolicy(policy);
}
