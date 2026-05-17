import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/data/datasources/local/client_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/follow_up_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/policy_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/reminder_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/datasources/remote/client_remote_data_source.dart';
import 'package:ninaivu/data/datasources/remote/follow_up_remote_data_source.dart';
import 'package:ninaivu/data/datasources/remote/policy_remote_data_source.dart';
import 'package:ninaivu/data/datasources/remote/reminder_remote_data_source.dart';
import 'package:ninaivu/data/datasources/remote/user_remote_data_source.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';

class SyncService {
  SyncService({
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    UserLocalDataSource? userLocalDataSource,
    ClientLocalDataSource? clientLocalDataSource,
    PolicyLocalDataSource? policyLocalDataSource,
    ReminderLocalDataSource? reminderLocalDataSource,
    FollowUpLocalDataSource? followUpLocalDataSource,
    UserRemoteDataSource? userRemoteDataSource,
    ClientRemoteDataSource? clientRemoteDataSource,
    PolicyRemoteDataSource? policyRemoteDataSource,
    ReminderRemoteDataSource? reminderRemoteDataSource,
    FollowUpRemoteDataSource? followUpRemoteDataSource,
    Connectivity? connectivity,
  }) : _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _clientLocalDataSource =
           clientLocalDataSource ?? ClientLocalDataSource(),
       _policyLocalDataSource =
           policyLocalDataSource ?? PolicyLocalDataSource(),
       _reminderLocalDataSource =
           reminderLocalDataSource ?? ReminderLocalDataSource(),
       _followUpLocalDataSource =
           followUpLocalDataSource ?? FollowUpLocalDataSource(),
       _userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSource(),
       _clientRemoteDataSource =
           clientRemoteDataSource ?? ClientRemoteDataSource(),
       _policyRemoteDataSource =
           policyRemoteDataSource ?? PolicyRemoteDataSource(),
       _reminderRemoteDataSource =
           reminderRemoteDataSource ?? ReminderRemoteDataSource(),
       _followUpRemoteDataSource =
           followUpRemoteDataSource ?? FollowUpRemoteDataSource(),
       _connectivity = connectivity ?? Connectivity();

  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final ClientLocalDataSource _clientLocalDataSource;
  final PolicyLocalDataSource _policyLocalDataSource;
  final ReminderLocalDataSource _reminderLocalDataSource;
  final FollowUpLocalDataSource _followUpLocalDataSource;
  final UserRemoteDataSource _userRemoteDataSource;
  final ClientRemoteDataSource _clientRemoteDataSource;
  final PolicyRemoteDataSource _policyRemoteDataSource;
  final ReminderRemoteDataSource _reminderRemoteDataSource;
  final FollowUpRemoteDataSource _followUpRemoteDataSource;
  final Connectivity _connectivity;

  static const int retryThreshold = 5;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<int> syncPendingData({bool removeSyncedQueueItems = true}) async {
    if (!await isOnline()) {
      return 0;
    }

    final items = await _syncQueueLocalDataSource.getPendingItems(
      retryThreshold: retryThreshold,
    );
    var syncedCount = 0;

    for (final item in items) {
      try {
        await _syncQueueItem(item);
        await _markLocalRecordSynced(item);
        await _syncQueueLocalDataSource.markSynced(item.id);
        if (removeSyncedQueueItems) {
          await _syncQueueLocalDataSource.deleteById(item.id);
        }
        syncedCount++;
      } catch (error, stackTrace) {
        final nextRetryCount = item.retryCount + 1;
        final nextStatus = nextRetryCount >= retryThreshold
            ? 'failed'
            : item.syncStatus;
        final errorMessage = error.toString().replaceFirst('Exception: ', '');

        FirebaseCrashlytics.instance.log(
          'Sync failure for ${item.tableName}/${item.recordId}: $errorMessage',
        );
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed syncing ${item.tableName}/${item.recordId}',
          fatal: false,
        );

        await _syncQueueLocalDataSource.markFailure(
          queueId: item.id,
          retryCount: nextRetryCount,
          lastError: errorMessage,
          syncStatus: nextStatus,
        );
      }
    }

    if (syncedCount > 0) {
      final preferences = await AppPreferences.getInstance();
      await preferences.setLastSyncTime(DateTime.now().millisecondsSinceEpoch);
    }

    return syncedCount;
  }

  Future<void> _syncQueueItem(SyncQueueModel item) async {
    switch (item.tableName) {
      case DatabaseTables.users:
        await _syncUser(item);
        return;
      case DatabaseTables.clients:
        await _syncClient(item);
        return;
      case DatabaseTables.policies:
        await _syncPolicy(item);
        return;
      case DatabaseTables.reminders:
        await _syncReminder(item);
        return;
      case DatabaseTables.followUps:
        await _syncFollowUp(item);
        return;
      default:
        throw Exception('Unsupported sync table ${item.tableName}');
    }
  }

  Future<void> _syncUser(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await _userRemoteDataSource.deleteUser(
        businessId: item.businessId,
        userId: item.recordId,
      );
      return;
    }

    final user = await _userLocalDataSource.getUserByIdIncludingDeleted(
      item.recordId,
    );
    if (user == null) {
      throw Exception('User ${item.recordId} missing locally');
    }
    await _userRemoteDataSource.upsertUser(user);
  }

  Future<void> _syncClient(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await _clientRemoteDataSource.deleteClient(
        businessId: item.businessId,
        clientId: item.recordId,
      );
      return;
    }

    final client = await _clientLocalDataSource.getClientByIdIncludingDeleted(
      item.recordId,
    );
    if (client == null) {
      throw Exception('Client ${item.recordId} missing locally');
    }
    await _clientRemoteDataSource.upsertClient(client);
  }

  Future<void> _syncPolicy(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await _policyRemoteDataSource.deletePolicy(
        businessId: item.businessId,
        policyId: item.recordId,
      );
      return;
    }

    final policy = await _policyLocalDataSource.getPolicyByIdIncludingDeleted(
      item.recordId,
    );
    if (policy == null) {
      throw Exception('Policy ${item.recordId} missing locally');
    }
    await _policyRemoteDataSource.upsertPolicy(policy);
  }

  Future<void> _syncReminder(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await _reminderRemoteDataSource.deleteReminder(
        businessId: item.businessId,
        reminderId: item.recordId,
      );
      return;
    }

    final reminder = await _reminderLocalDataSource
        .getReminderByIdIncludingDeleted(item.recordId);
    if (reminder == null) {
      throw Exception('Reminder ${item.recordId} missing locally');
    }
    await _reminderRemoteDataSource.upsertReminder(reminder);
  }

  Future<void> _syncFollowUp(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await _followUpRemoteDataSource.deleteFollowUp(
        businessId: item.businessId,
        followUpId: item.recordId,
      );
      return;
    }

    final followUp = await _followUpLocalDataSource
        .getFollowUpByIdIncludingDeleted(item.recordId);
    if (followUp == null) {
      throw Exception('Follow-up ${item.recordId} missing locally');
    }
    await _followUpRemoteDataSource.upsertFollowUp(followUp);
  }

  Future<void> _markLocalRecordSynced(SyncQueueModel item) async {
    switch (item.tableName) {
      case DatabaseTables.users:
        await _userLocalDataSource.markUserSynced(item.recordId);
        return;
      case DatabaseTables.clients:
        await _clientLocalDataSource.markClientSynced(item.recordId);
        return;
      case DatabaseTables.policies:
        await _policyLocalDataSource.markPolicySynced(item.recordId);
        return;
      case DatabaseTables.reminders:
        await _reminderLocalDataSource.markReminderSynced(item.recordId);
        return;
      case DatabaseTables.followUps:
        await _followUpLocalDataSource.markFollowUpSynced(item.recordId);
        return;
      default:
        throw Exception('Unsupported sync table ${item.tableName}');
    }
  }
}
