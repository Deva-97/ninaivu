import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class GetExpiredPoliciesUseCase {
  GetExpiredPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<Policy>> call() => _repository.getExpiredPolicies();
}
