import 'package:insurance_reminders/domain/entities/reminder.dart';
import 'package:insurance_reminders/domain/repositories/reminder_repository.dart';

class GetReminderByIdUseCase {
  GetReminderByIdUseCase(this._repository);

  final ReminderRepository _repository;

  Future<Reminder?> call(String reminderId) =>
      _repository.getReminderById(reminderId);
}
