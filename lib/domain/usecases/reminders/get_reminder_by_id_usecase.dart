import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/repositories/reminder_repository.dart';

class GetReminderByIdUseCase {
  GetReminderByIdUseCase(this._repository);

  final ReminderRepository _repository;

  Future<Reminder?> call(String reminderId) =>
      _repository.getReminderById(reminderId);
}
