import 'package:insurance_reminders/domain/entities/reminder.dart';
import 'package:insurance_reminders/domain/repositories/reminder_repository.dart';

class GetRemindersUseCase {
  GetRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  Future<List<Reminder>> call({String filter = 'today'}) =>
      _repository.getReminders(filter: filter);
}
