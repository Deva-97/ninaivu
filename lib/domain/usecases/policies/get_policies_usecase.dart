import 'package:insurance_reminders/domain/entities/policy.dart';
import 'package:insurance_reminders/domain/repositories/policy_repository.dart';

class GetPoliciesUseCase {
  GetPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<Policy>> call({
    String? query,
    int limit = 50,
    int offset = 0,
  }) => _repository.getPolicies(query: query, limit: limit, offset: offset);
}
