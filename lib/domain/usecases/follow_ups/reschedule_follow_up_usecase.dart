import 'package:ninaivu/domain/repositories/follow_up_repository.dart';

class RescheduleFollowUpUseCase {
  RescheduleFollowUpUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<void> call({
    required String followUpId,
    required int scheduledAt,
  }) {
    return _repository.rescheduleFollowUp(
      followUpId: followUpId,
      scheduledAt: scheduledAt,
    );
  }
}
