import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/repositories/reminder_repository.dart';

class GetRemindersUseCase {
  GetRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  Future<List<Reminder>> call({String filter = 'pending'}) =>
      _repository.getReminders(filter: filter);
}
