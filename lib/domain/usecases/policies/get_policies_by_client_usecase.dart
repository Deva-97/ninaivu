import 'package:insurance_reminders/domain/entities/policy.dart';
import 'package:insurance_reminders/domain/repositories/policy_repository.dart';

class GetPoliciesByClientUseCase {
  GetPoliciesByClientUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<Policy>> call(String clientId) =>
      _repository.getPoliciesByClient(clientId);
}
