import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/data/repositories/follow_up_repository_impl.dart';

import '../../helpers/offline_first_test_fakes.dart';

void main() {
  group('FollowUpRepositoryImpl', () {
    test(
      'addFollowUp writes locally and enqueues create for offline sync',
      () async {
        final currentUser = testUser();
        final local = FakeFollowUpLocalDataSource();
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final users = FakeUserLocalDataSource(currentUser: currentUser);
        final repository = FollowUpRepositoryImpl(
          localDataSource: local,
          userLocalDataSource: users,
          syncQueueLocalDataSource: queue,
          syncService: sync,
        );

        final created = await repository.addFollowUp(
          testFollowUp(id: '', businessId: '', createdBy: ''),
        );

        expect(local.insertedFollowUps, hasLength(1));
        expect(created.businessId, currentUser.businessId);
        expect(created.createdBy, currentUser.id);
        expect(created.syncStatus, 'pending_create');
        expect(queue.enqueuedItems.single.tableName, 'follow_ups');
        expect(queue.enqueuedItems.single.operation, 'create');
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );

    test(
      'rescheduleFollowUp updates local schedule and queues pending update',
      () async {
        final currentUser = testUser();
        final existing = testFollowUp();
        final local = FakeFollowUpLocalDataSource(
          followUpsById: {existing.id: existing},
        );
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final users = FakeUserLocalDataSource(currentUser: currentUser);
        final repository = FollowUpRepositoryImpl(
          localDataSource: local,
          userLocalDataSource: users,
          syncQueueLocalDataSource: queue,
          syncService: sync,
        );
        final nextDate = testNowMs + const Duration(days: 5).inMilliseconds;

        await repository.rescheduleFollowUp(
          followUpId: existing.id,
          scheduledAt: nextDate,
        );

        expect(local.rescheduleRequests, hasLength(1));
        expect(local.rescheduleRequests.single.followUpId, existing.id);
        expect(local.rescheduleRequests.single.scheduledAt, nextDate);
        expect(queue.enqueuedItems.single.operation, 'update');
        expect(queue.enqueuedItems.single.syncStatus, 'pending_update');
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );
  });
}
