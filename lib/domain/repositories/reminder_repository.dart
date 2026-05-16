import 'package:insurance_reminders/domain/entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getReminders({
    String filter = 'today',
  });
  Future<Reminder?> getReminderById(String reminderId);
  Future<void> markReminderCompleted(String reminderId);
}
