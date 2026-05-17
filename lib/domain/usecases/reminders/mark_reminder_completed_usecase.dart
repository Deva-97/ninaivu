import 'package:ninaivu/domain/repositories/reminder_repository.dart';

class MarkReminderCompletedUseCase {
  MarkReminderCompletedUseCase(this._repository);

  final ReminderRepository _repository;

  Future<void> call(String reminderId) =>
      _repository.markReminderCompleted(reminderId);
}
