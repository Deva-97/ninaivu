import 'package:ninaivu/domain/repositories/policy_repository.dart';

class UpdatePolicyRenewalStatusUseCase {
  UpdatePolicyRenewalStatusUseCase(this._repository);

  final PolicyRepository _repository;

  Future<void> call({
    required String policyId,
    required String renewalStatus,
  }) {
    return _repository.updateRenewalStatus(
      policyId: policyId,
      renewalStatus: renewalStatus,
    );
  }
}
