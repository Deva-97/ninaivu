import 'package:insurance_reminders/core/services/notification_service.dart';
import 'package:insurance_reminders/data/models/reminder_model.dart';

class ReminderSchedulerService {
  ReminderSchedulerService({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService.instance;

  final NotificationService _notificationService;

  Future<void> scheduleReminders({
    required List<ReminderModel> reminders,
    required String clientName,
    required String policyNumber,
    required String companyName,
  }) async {
    for (final reminder in reminders) {
      if (reminder.notificationId == null) {
        continue;
      }

      await _notificationService.scheduleReminder(
        notificationId: reminder.notificationId!,
        title: 'Policy renewal reminder',
        body:
            '$clientName • $policyNumber • $companyName • ${reminder.reminderType}',
        scheduledDateTime: DateTime.fromMillisecondsSinceEpoch(
          reminder.reminderDateTime,
        ),
        payload: reminder.policyId,
      );
    }
  }

  Future<void> cancelReminders(List<ReminderModel> reminders) async {
    for (final reminder in reminders) {
      final notificationId = reminder.notificationId;
      if (notificationId == null) {
        continue;
      }
      await _notificationService.cancelReminder(notificationId);
    }
  }
}
