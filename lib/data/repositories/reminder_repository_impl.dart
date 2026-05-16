import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/core/services/sync_service.dart';
import 'package:insurance_reminders/core/database/database_tables.dart';
import 'package:insurance_reminders/core/services/notification_service.dart';
import 'package:insurance_reminders/data/datasources/local/reminder_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/data/models/reminder_model.dart';
import 'package:insurance_reminders/data/models/sync_queue_model.dart';
import 'package:insurance_reminders/domain/entities/reminder.dart';
import 'package:insurance_reminders/domain/repositories/reminder_repository.dart';
import 'package:uuid/uuid.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    ReminderLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    NotificationService? notificationService,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    SyncService? syncService,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? ReminderLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _notificationService = notificationService ?? NotificationService.instance,
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  final ReminderLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final NotificationService _notificationService;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final SyncService _syncService;
  final Uuid _uuid;

  @override
  Future<List<Reminder>> getReminders({String filter = 'pending'}) async {
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
  Future<Reminder?> getReminderById(String reminderId) async {
    final currentUser = await _requireCurrentUser();
    final reminder = await _localDataSource.getReminderById(reminderId);
    if (reminder == null) {
      return null;
    }
    _ensureReminderAccess(currentUser, reminder);
    return reminder;
  }

  @override
  Future<void> markReminderCompleted(String reminderId) async {
    final currentUser = await _requireCurrentUser();
    final reminder = await _localDataSource.getReminderById(reminderId);
    if (reminder == null) {
      throw Exception('Reminder not found');
    }
    _ensureReminderAccess(currentUser, reminder);

    if (reminder.notificationId != null) {
      await _notificationService.cancelReminder(reminder.notificationId!);
    }
    await _localDataSource.markReminderCompleted(reminderId);
    final updatedReminder = reminder.copyWith(
      status: 'completed',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _enqueue(updatedReminder, 'update', 'pending_update');
    await _syncService.syncPendingData();
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }

  void _ensureReminderAccess(AppUserModel currentUser, Reminder reminder) {
    final role = currentUser.role.toAppRole();
    if (!PermissionHelper.canManageReminders(role)) {
      throw Exception('You do not have permission to manage reminders.');
    }
    if (!PermissionHelper.canAccessOwnRecord(
      role: role,
      currentUserId: currentUser.id,
      createdBy: reminder.createdBy,
      agentId: reminder.agentId,
      assignedTo: reminder.assignedTo,
    )) {
      throw Exception('You can only access your own reminders.');
    }
  }

  Future<void> _enqueue(
    ReminderModel reminder,
    String operation,
    String syncStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: reminder.businessId,
        tableName: DatabaseTables.reminders,
        recordId: reminder.id,
        operation: operation,
        payload: reminder.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: syncStatus,
      ),
    );
  }
}
