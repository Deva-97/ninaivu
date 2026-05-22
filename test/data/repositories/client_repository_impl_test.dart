import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';

import '../../helpers/offline_first_test_fakes.dart';

void main() {
  group('ClientRepositoryImpl', () {
    test('addClient writes locally, enqueues create, and triggers best-effort sync', () async {
      final currentUser = testUser();
      final local = FakeClientLocalDataSource();
      final queue = FakeSyncQueueLocalDataSource();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = ClientRepositoryImpl(
        localDataSource: local,
        syncQueueLocalDataSource: queue,
        userLocalDataSource: users,
        syncService: sync,
      );

      final created = await repository.addClient(
        name: 'Ravi',
        mobile: '9876543210',
        areaCity: 'Chennai',
      );

      expect(local.insertedClients, hasLength(1));
      expect(created.businessId, currentUser.businessId);
      expect(created.createdBy, currentUser.id);
      expect(created.syncStatus, 'pending_create');
      expect(queue.enqueuedItems, hasLength(1));
      expect(queue.enqueuedItems.single.tableName, 'clients');
      expect(queue.enqueuedItems.single.recordId, created.id);
      expect(queue.enqueuedItems.single.operation, 'create');
      expect(queue.enqueuedItems.single.syncStatus, 'pending_create');
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });

    test('updateClient preserves ownership metadata and enqueues pending update', () async {
      final currentUser = testUser();
      final existing = testClient();
      final local = FakeClientLocalDataSource(
        clientsById: {existing.id: existing},
      );
      final queue = FakeSyncQueueLocalDataSource();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = ClientRepositoryImpl(
        localDataSource: local,
        syncQueueLocalDataSource: queue,
        userLocalDataSource: users,
        syncService: sync,
      );

      final updated = await repository.updateClient(
        testClient(
          id: existing.id,
          businessId: 'wrong-business',
          createdBy: 'wrong-user',
          assignedTo: 'agent-2',
        ),
      );

      expect(local.updatedClients, hasLength(1));
      expect(updated.businessId, existing.businessId);
      expect(updated.createdBy, existing.createdBy);
      expect(updated.syncStatus, 'pending_update');
      expect(queue.enqueuedItems.single.operation, 'update');
      expect(queue.enqueuedItems.single.syncStatus, 'pending_update');
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });

    test('deleteClient soft deletes locally and enqueues pending delete', () async {
      final currentUser = testUser();
      final existing = testClient();
      final local = FakeClientLocalDataSource(
        clientsById: {existing.id: existing},
      );
      final queue = FakeSyncQueueLocalDataSource();
      final sync = FakeSyncService();
      final users = FakeUserLocalDataSource(currentUser: currentUser);
      final repository = ClientRepositoryImpl(
        localDataSource: local,
        syncQueueLocalDataSource: queue,
        userLocalDataSource: users,
        syncService: sync,
      );

      await repository.deleteClient(existing.id);

      expect(local.softDeletedClientIds, [existing.id]);
      expect(queue.enqueuedItems, hasLength(1));
      expect(queue.enqueuedItems.single.operation, 'delete');
      expect(queue.enqueuedItems.single.recordId, existing.id);
      expect(queue.enqueuedItems.single.syncStatus, 'pending_delete');
      expect(sync.syncPendingDataBestEffortCallCount, 1);
    });
  });
}
