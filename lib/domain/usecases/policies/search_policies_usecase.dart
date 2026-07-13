import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class SearchPoliciesUseCase {
  SearchPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  Future<List<Policy>> call({required String query, String? clientId}) {
    return _repository.searchPolicies(query: query, clientId: clientId);
  }
}
