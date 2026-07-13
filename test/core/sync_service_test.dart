import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/sync_service.dart';
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
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncService offline-first behavior', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await AppPreferences.getInstance();
      await preferences.clearSession();
      await preferences.setLastSyncTime(null);
    });

    test('returns 0 without touching the queue when offline', () async {
      final queue = FakeSyncQueueLocalDataSource(
        pendingItems: [_queueItem(recordId: 'user-1')],
      );
      final remote = FakeUserRemoteDataSource();

      final service = _buildService(
        connectivityResults: [ConnectivityResult.none],
        syncQueueLocalDataSource: queue,
        userRemoteDataSource: remote,
      );

      final syncedCount = await service.syncPendingData();

      expect(syncedCount, 0);
      expect(queue.getPendingItemsCallCount, 0);
      expect(queue.markSyncedIds, isEmpty);
      expect(queue.deletedIds, isEmpty);
      expect(remote.upsertedUsers, isEmpty);
    });

    test(
      'syncs queued user changes and updates local sync bookkeeping',
      () async {
        final user = _user(id: 'user-1');
        final queue = FakeSyncQueueLocalDataSource(
          pendingItems: [_queueItem(recordId: user.id)],
        );
        final userLocal = FakeUserLocalDataSource(
          currentUser: user,
          usersById: {user.id: user},
        );
        final remote = FakeUserRemoteDataSource();

        final service = _buildService(
          connectivityResults: [ConnectivityResult.wifi],
          syncQueueLocalDataSource: queue,
          userLocalDataSource: userLocal,
          userRemoteDataSource: remote,
        );

        final syncedCount = await service.syncPendingData();
        final preferences = await AppPreferences.getInstance();

        expect(syncedCount, 1);
        expect(queue.getPendingItemsCallCount, 1);
        expect(queue.markSyncedIds, ['queue-1']);
        expect(queue.deletedIds, ['queue-1']);
        expect(queue.failureUpdates, isEmpty);
        expect(remote.upsertedUsers.map((item) => item.id), [user.id, user.id]);
        expect(userLocal.markUserSyncedIds, [user.id, user.id]);
        expect(preferences.lastSyncTime, isNotNull);
      },
    );

    test(
      'persists retry state and throws when syncing a queued item fails',
      () async {
        final user = _user(id: 'user-2');
        final queue = FakeSyncQueueLocalDataSource(
          pendingItems: [_queueItem(recordId: user.id)],
        );
        final userLocal = FakeUserLocalDataSource(usersById: {user.id: user});
        final remote = FakeUserRemoteDataSource(
          upsertError: Exception('remote write failed'),
        );
        final logs = <String>[];
        final recordedReasons = <String>[];

        final service = _buildService(
          connectivityResults: [ConnectivityResult.mobile],
          syncQueueLocalDataSource: queue,
          userLocalDataSource: userLocal,
          userRemoteDataSource: remote,
          logWriter: (message) async {
            logs.add(message);
          },
          errorRecorder:
              (error, stackTrace, {required reason, required fatal}) async {
                recordedReasons.add(reason);
              },
        );

        await expectLater(
          service.syncPendingData(),
          throwsA(
            isA<SyncFailureException>().having(
              (error) => error.message,
              'message',
              contains('remote write failed'),
            ),
          ),
        );

        expect(queue.markSyncedIds, isEmpty);
        expect(queue.deletedIds, isEmpty);
        expect(queue.failureUpdates, hasLength(1));
        expect(queue.failureUpdates.single.queueId, 'queue-1');
        expect(queue.failureUpdates.single.retryCount, 1);
        expect(queue.failureUpdates.single.syncStatus, 'pending_create');
        expect(queue.failureUpdates.single.lastError, 'remote write failed');
        expect(logs.single, contains('remote write failed'));
        expect(recordedReasons.single, 'Failed syncing users/${user.id}');
      },
    );

    test(
      'best-effort sync swallows failures and leaves the retry state intact',
      () async {
        final user = _user(id: 'user-3');
        final queue = FakeSyncQueueLocalDataSource(
          pendingItems: [_queueItem(recordId: user.id)],
        );
        final userLocal = FakeUserLocalDataSource(usersById: {user.id: user});
        final remote = FakeUserRemoteDataSource(
          upsertError: Exception('temporary outage'),
        );
        final recordedReasons = <String>[];

        final service = _buildService(
          connectivityResults: [ConnectivityResult.wifi],
          syncQueueLocalDataSource: queue,
          userLocalDataSource: userLocal,
          userRemoteDataSource: remote,
          logWriter: (_) async {},
          errorRecorder:
              (error, stackTrace, {required reason, required fatal}) async {
                recordedReasons.add(reason);
              },
        );

        final syncedCount = await service.syncPendingDataBestEffort();

        expect(syncedCount, 0);
        expect(queue.failureUpdates, hasLength(1));
        expect(queue.failureUpdates.single.lastError, 'temporary outage');
        expect(
          recordedReasons,
          contains('Best-effort sync deferred queued changes'),
        );
      },
    );
  });
}

SyncService _buildService({
  required List<ConnectivityResult> connectivityResults,
  required FakeSyncQueueLocalDataSource syncQueueLocalDataSource,
  FakeUserLocalDataSource? userLocalDataSource,
  required FakeUserRemoteDataSource userRemoteDataSource,
  SyncLogWriter? logWriter,
  SyncErrorRecorder? errorRecorder,
}) {
  return SyncService(
    syncQueueLocalDataSource: syncQueueLocalDataSource,
    userLocalDataSource: userLocalDataSource ?? FakeUserLocalDataSource(),
    clientLocalDataSource: FakeClientLocalDataSource(),
    policyLocalDataSource: FakePolicyLocalDataSource(),
    reminderLocalDataSource: FakeReminderLocalDataSource(),
    followUpLocalDataSource: FakeFollowUpLocalDataSource(),
    userRemoteDataSource: userRemoteDataSource,
    clientRemoteDataSource: FakeClientRemoteDataSource(),
    policyRemoteDataSource: FakePolicyRemoteDataSource(),
    reminderRemoteDataSource: FakeReminderRemoteDataSource(),
    followUpRemoteDataSource: FakeFollowUpRemoteDataSource(),
    onlineStatusChecker: () async {
      return !connectivityResults.contains(ConnectivityResult.none);
    },
    logWriter: logWriter,
    errorRecorder: errorRecorder,
  );
}

AppUserModel _user({required String id}) {
  final now = DateTime(2026, 1, 1).millisecondsSinceEpoch;
  return AppUserModel(
    id: id,
    businessId: 'business-1',
    name: 'Test User',
    role: AppRole.admin.value,
    status: 'active',
    profileCompleted: true,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
    syncStatus: 'pending_create',
  );
}

SyncQueueModel _queueItem({required String recordId}) {
  final now = DateTime(2026, 1, 1).millisecondsSinceEpoch;
  return SyncQueueModel(
    id: 'queue-1',
    businessId: 'business-1',
    tableName: DatabaseTables.users,
    recordId: recordId,
    operation: 'create',
    payload: const {'id': 'user'},
    retryCount: 0,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'pending_create',
  );
}

class FakeSyncQueueLocalDataSource extends SyncQueueLocalDataSource {
  FakeSyncQueueLocalDataSource({required this.pendingItems});

  final List<SyncQueueModel> pendingItems;
  int getPendingItemsCallCount = 0;
  final List<String> markSyncedIds = <String>[];
  final List<String> deletedIds = <String>[];
  final List<FailureUpdate> failureUpdates = <FailureUpdate>[];

  @override
  Future<List<SyncQueueModel>> getPendingItems({
    int limit = 100,
    int retryThreshold = 5,
  }) async {
    getPendingItemsCallCount++;
    return pendingItems;
  }

  @override
  Future<void> markSynced(String queueId) async {
    markSyncedIds.add(queueId);
  }

  @override
  Future<void> markFailure({
    required String queueId,
    required int retryCount,
    required String lastError,
    required String syncStatus,
  }) async {
    failureUpdates.add(
      FailureUpdate(
        queueId: queueId,
        retryCount: retryCount,
        lastError: lastError,
        syncStatus: syncStatus,
      ),
    );
  }

  @override
  Future<void> deleteById(String queueId) async {
    deletedIds.add(queueId);
  }
}

class FailureUpdate {
  const FailureUpdate({
    required this.queueId,
    required this.retryCount,
    required this.lastError,
    required this.syncStatus,
  });

  final String queueId;
  final int retryCount;
  final String lastError;
  final String syncStatus;
}

class FakeUserLocalDataSource extends UserLocalDataSource {
  FakeUserLocalDataSource({
    this.currentUser,
    Map<String, AppUserModel>? usersById,
  }) : usersById = usersById ?? <String, AppUserModel>{};

  final AppUserModel? currentUser;
  final Map<String, AppUserModel> usersById;
  final List<String> markUserSyncedIds = <String>[];

  @override
  Future<AppUserModel?> getCurrentUser() async => currentUser;

  @override
  Future<AppUserModel?> getUserByIdIncludingDeleted(String id) async {
    return usersById[id];
  }

  @override
  Future<void> markUserSynced(String id) async {
    markUserSyncedIds.add(id);
  }
}

class FakeUserRemoteDataSource extends UserRemoteDataSource {
  FakeUserRemoteDataSource({this.upsertError});

  final Exception? upsertError;
  final List<AppUserModel> upsertedUsers = <AppUserModel>[];

  @override
  Future<void> upsertUser(AppUserModel user) async {
    if (upsertError != null) {
      throw upsertError!;
    }
    upsertedUsers.add(user);
  }
}

class FakeClientLocalDataSource extends ClientLocalDataSource {}

class FakePolicyLocalDataSource extends PolicyLocalDataSource {}

class FakeReminderLocalDataSource extends ReminderLocalDataSource {}

class FakeFollowUpLocalDataSource extends FollowUpLocalDataSource {}

class FakeClientRemoteDataSource extends ClientRemoteDataSource {}

class FakePolicyRemoteDataSource extends PolicyRemoteDataSource {}

class FakeReminderRemoteDataSource extends ReminderRemoteDataSource {}

class FakeFollowUpRemoteDataSource extends FollowUpRemoteDataSource {}
