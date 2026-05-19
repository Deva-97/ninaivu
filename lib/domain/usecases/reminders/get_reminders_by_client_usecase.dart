import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/repositories/reminder_repository.dart';

class GetRemindersByClientUseCase {
  GetRemindersByClientUseCase(this._repository);

  final ReminderRepository _repository;

  Future<List<Reminder>> call(String clientId) => _repository.getRemindersByClient(clientId);
}
