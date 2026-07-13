import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/data/repositories/reminder_repository_impl.dart';

import '../../helpers/offline_first_test_fakes.dart';

void main() {
  group('ReminderRepositoryImpl', () {
    test(
      'markReminderCompleted cancels the notification and queues an update',
      () async {
        final currentUser = testUser();
        final reminder = testReminder();
        final local = FakeReminderLocalDataSource(
          remindersById: {reminder.id: reminder},
        );
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final users = FakeUserLocalDataSource(currentUser: currentUser);
        final cancelledNotificationIds = <int>[];
        final repository = ReminderRepositoryImpl(
          localDataSource: local,
          userLocalDataSource: users,
          syncQueueLocalDataSource: queue,
          syncService: sync,
          notificationCanceller: (notificationId) async {
            cancelledNotificationIds.add(notificationId);
          },
        );

        await repository.markReminderCompleted(reminder.id);

        expect(cancelledNotificationIds, [reminder.notificationId]);
        expect(local.completedReminderIds, [reminder.id]);
        expect(queue.enqueuedItems, hasLength(1));
        expect(queue.enqueuedItems.single.tableName, 'reminders');
        expect(queue.enqueuedItems.single.operation, 'update');
        expect(queue.enqueuedItems.single.syncStatus, 'pending_update');
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );

    test(
      'markReminderRenewed updates linked policy and enqueues both records',
      () async {
        final currentUser = testUser();
        final reminder = testReminder();
        final policy = testPolicy(id: reminder.policyId);
        final local = FakeReminderLocalDataSource(
          remindersById: {reminder.id: reminder},
        );
        final policies = FakePolicyLocalDataSource(
          policiesById: {policy.id: policy},
        );
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final users = FakeUserLocalDataSource(currentUser: currentUser);
        final cancelledNotificationIds = <int>[];
        final repository = ReminderRepositoryImpl(
          localDataSource: local,
          policyLocalDataSource: policies,
          userLocalDataSource: users,
          syncQueueLocalDataSource: queue,
          syncService: sync,
          notificationCanceller: (notificationId) async {
            cancelledNotificationIds.add(notificationId);
          },
        );

        await repository.markReminderRenewed(reminder.id);

        expect(cancelledNotificationIds, [reminder.notificationId]);
        expect(local.renewedReminderIds, [reminder.id]);
        expect(policies.renewalUpdates, hasLength(1));
        expect(policies.renewalUpdates.single.policyId, policy.id);
        expect(policies.renewalUpdates.single.renewalStatus, 'Renewed');
        expect(policies.renewalUpdates.single.policyStatus, 'Renewed');
        expect(queue.enqueuedItems, hasLength(2));
        expect(queue.enqueuedItems.first.tableName, 'policies');
        expect(queue.enqueuedItems.first.operation, 'update');
        expect(queue.enqueuedItems.last.tableName, 'reminders');
        expect(queue.enqueuedItems.last.operation, 'update');
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );
  });
}
