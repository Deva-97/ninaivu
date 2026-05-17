import 'package:ninaivu/domain/repositories/policy_repository.dart';

class DeletePolicyUseCase {
  DeletePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<void> call(String policyId) => _repository.deletePolicy(policyId);
}
