class SyncStatusHelper {
  SyncStatusHelper._();

  // Small user-facing labels for local/remote backup state.
  static String labelFor({
    required String recordSyncStatus,
    required bool hasFailedQueueItem,
    required bool hasPendingQueueItem,
  }) {
    if (hasFailedQueueItem) {
      return 'Sync failed';
    }
    if (hasPendingQueueItem) {
      return 'Retrying';
    }

    switch (recordSyncStatus.trim().toLowerCase()) {
      case 'synced':
        return 'Backed up';
      case 'pending_create':
      case 'pending_update':
      case 'pending_delete':
        return 'Backup pending';
      case 'failed':
        return 'Sync failed';
      default:
        return 'Saved offline';
    }
  }
}
