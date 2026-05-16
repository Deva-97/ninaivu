import 'package:insurance_reminders/domain/repositories/follow_up_repository.dart';

class MarkFollowUpCompletedUseCase {
  MarkFollowUpCompletedUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<void> call(String followUpId) =>
      _repository.markFollowUpCompleted(followUpId);
}
