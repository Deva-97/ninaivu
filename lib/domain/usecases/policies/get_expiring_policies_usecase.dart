import 'package:insurance_reminders/domain/entities/policy.dart';
import 'package:insurance_reminders/domain/repositories/policy_repository.dart';

class GetExpiringPoliciesUseCase {
  GetExpiringPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<Policy>> call({int withinDays = 30}) =>
      _repository.getExpiringPolicies(withinDays: withinDays);
}
