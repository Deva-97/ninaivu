import 'package:ninaivu/domain/entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getReminders({
    String filter = 'pending',
  });
  Future<Reminder?> getReminderById(String reminderId);
  Future<void> markReminderCompleted(String reminderId);
}
