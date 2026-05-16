import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/core/services/notification_service.dart';
import 'package:insurance_reminders/data/datasources/local/reminder_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/domain/entities/reminder.dart';
import 'package:insurance_reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    ReminderLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    NotificationService? notificationService,
  }) : _localDataSource = localDataSource ?? ReminderLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _notificationService = notificationService ?? NotificationService.instance;

  final ReminderLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final NotificationService _notificationService;

  @override
  Future<List<Reminder>> getReminders({String filter = 'today'}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getReminders(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      filter: filter,
    );
  }

  @override
  Future<Reminder?> getReminderById(String reminderId) =>
      _localDataSource.getReminderById(reminderId);

  @override
  Future<void> markReminderCompleted(String reminderId) async {
    final reminder = await _localDataSource.getReminderById(reminderId);
    if (reminder == null) {
      throw Exception('Reminder not found');
    }

    if (reminder.notificationId != null) {
      await _notificationService.cancelReminder(reminder.notificationId!);
    }
    await _localDataSource.markReminderCompleted(reminderId);
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }
}
