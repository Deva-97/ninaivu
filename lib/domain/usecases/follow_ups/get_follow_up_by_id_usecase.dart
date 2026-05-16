import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/repositories/follow_up_repository.dart';

class GetFollowUpByIdUseCase {
  GetFollowUpByIdUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<FollowUp?> call(String followUpId) =>
      _repository.getFollowUpById(followUpId);
}
