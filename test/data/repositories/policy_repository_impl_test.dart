import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';

import '../../helpers/offline_first_test_fakes.dart';

void main() {
  group('PolicyRepositoryImpl', () {
    test('addPolicy refreshes reminders, enqueues records, and schedules upcoming notifications', () async {
      final currentUser = testUser();
      final client = testClient();
      final generatedReminders = [
        testReminder(id: 'rem-1', status: 'pending'),
        testReminder(id: 'rem-2', status: 'missed', notificationId: 1002),
      ];
      final local = FakePolicyLocalDataSource();
      final clients = FakeClientLocalDataSource(clientsById: {client.id: client});
      final reminders = FakeReminderLocalDataSource();
      final queue = FakeSyncQueueLocalDataSource();
      final generator = FakeReminderGeneratorService(generatedReminders);
      final scheduler = FakeReminderSchedulerService();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = PolicyRepositoryImpl(
        localDataSource: local,
        clientLocalDataSource: clients,
        userLocalDataSource: users,
        reminderLocalDataSource: reminders,
        syncQueueLocalDataSource: queue,
        reminderGeneratorService: generator,
        reminderSchedulerService: scheduler,
        syncService: sync,
      );

      final created = await repository.addPolicy(testPolicy(clientId: client.id));

      expect(local.insertedPolicies, hasLength(1));
      expect(generator.generatedForPolicies.single.id, created.id);
      expect(reminders.insertedReminderBatches, hasLength(1));
      expect(reminders.insertedReminderBatches.single, generatedReminders);
      expect(queue.enqueuedItems, hasLength(3));
      expect(queue.enqueuedItems.first.tableName, 'reminders');
      expect(queue.enqueuedItems.last.tableName, 'policies');
      expect(scheduler.scheduleRequests, hasLength(1));
      expect(scheduler.scheduleRequests.single.clientName, client.name);
      expect(
        scheduler.scheduleRequests.single.reminders.map((item) => item.id),
        ['rem-1'],
      );
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });

    test('updateRenewalStatus queues a policy update and preserves renewal intent', () async {
      final currentUser = testUser();
      final existing = testPolicy();
      final local = FakePolicyLocalDataSource(
        policiesById: {existing.id: existing},
      );
      final queue = FakeSyncQueueLocalDataSource();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = PolicyRepositoryImpl(
        localDataSource: local,
        userLocalDataSource: users,
        syncQueueLocalDataSource: queue,
        syncService: sync,
      );

      await repository.updateRenewalStatus(
        policyId: existing.id,
        renewalStatus: 'Renewed',
      );

      expect(local.renewalUpdates, hasLength(1));
      expect(local.renewalUpdates.single.policyId, existing.id);
      expect(local.renewalUpdates.single.renewalStatus, 'Renewed');
      expect(local.renewalUpdates.single.policyStatus, 'Renewed');
      expect(queue.enqueuedItems.single.tableName, 'policies');
      expect(queue.enqueuedItems.single.operation, 'update');
      expect(queue.enqueuedItems.single.syncStatus, 'pending_update');
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });

    test('deletePolicy cancels existing reminders and enqueues delete records', () async {
      final currentUser = testUser();
      final existing = testPolicy();
      final oldReminder = testReminder(policyId: existing.id);
      final local = FakePolicyLocalDataSource(
        policiesById: {existing.id: existing},
      );
      final reminders = FakeReminderLocalDataSource(
        remindersByPolicy: {
          existing.id: [oldReminder],
        },
      );
      final queue = FakeSyncQueueLocalDataSource();
      final scheduler = FakeReminderSchedulerService();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = PolicyRepositoryImpl(
        localDataSource: local,
        userLocalDataSource: users,
        reminderLocalDataSource: reminders,
        syncQueueLocalDataSource: queue,
        reminderSchedulerService: scheduler,
        syncService: sync,
      );

      await repository.deletePolicy(existing.id);

      expect(scheduler.cancelledReminderBatches, hasLength(1));
      expect(scheduler.cancelledReminderBatches.single.single.id, oldReminder.id);
      expect(reminders.softDeletedPolicyIds, [existing.id]);
      expect(local.softDeletedPolicyIds, [existing.id]);
      expect(queue.enqueuedItems, hasLength(2));
      expect(queue.enqueuedItems.first.tableName, 'reminders');
      expect(queue.enqueuedItems.first.operation, 'delete');
      expect(queue.enqueuedItems.last.tableName, 'policies');
      expect(queue.enqueuedItems.last.operation, 'delete');
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });
  });
}
