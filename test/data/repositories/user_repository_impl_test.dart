import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/data/repositories/user_repository_impl.dart';

import '../../helpers/offline_first_test_fakes.dart';

void main() {
  group('UserRepositoryImpl', () {
    test(
      'createAgent saves locally, enqueues create, and triggers sync',
      () async {
        final currentUser = testUser();
        final local = FakeUserLocalDataSource(currentUser: currentUser);
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final repository = UserRepositoryImpl(
          localDataSource: local,
          syncQueueLocalDataSource: queue,
          syncService: sync,
        );

        final created = await repository.createAgent(
          name: 'Agent One',
          mobile: '9999999999',
        );

        expect(local.savedUsers, hasLength(1));
        expect(created.businessId, currentUser.businessId);
        expect(created.createdBy, currentUser.id);
        expect(created.role, 'agent');
        expect(created.syncStatus, 'pending_create');
        expect(queue.enqueuedItems.single.tableName, 'users');
        expect(queue.enqueuedItems.single.operation, 'create');
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );

    test(
      'updateCurrentUserProfileImage enqueues a minimal update payload',
      () async {
        final currentUser = testUser();
        final local = FakeUserLocalDataSource(
          currentUser: currentUser,
          usersById: {currentUser.id: currentUser},
        );
        final queue = FakeSyncQueueLocalDataSource();
        final sync = FakeSyncService();
        final repository = UserRepositoryImpl(
          localDataSource: local,
          syncQueueLocalDataSource: queue,
          syncService: sync,
        );

        final updated = await repository.updateCurrentUserProfileImage(
          profileImageData: 'base64-image',
        );

        expect(local.savedUsers, hasLength(1));
        expect(updated.profileImageData, 'base64-image');
        expect(updated.syncStatus, 'pending_update');
        expect(queue.enqueuedItems.single.operation, 'update');
        expect(
          queue.enqueuedItems.single.payload,
          containsPair('id', currentUser.id),
        );
        expect(queue.enqueuedItems.single.payload, contains('updated_at'));
        expect(
          queue.enqueuedItems.single.payload,
          containsPair('sync_status', 'pending_update'),
        );
        expect(sync.syncPendingDataBestEffortCallCount, 1);
      },
    );
  });
}
