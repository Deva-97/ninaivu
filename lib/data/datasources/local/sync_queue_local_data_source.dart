import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueLocalDataSource {
  SyncQueueLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  static Future<void> Function()? onItemEnqueued;

  final DatabaseHelper _databaseHelper;

  Future<void> enqueue(SyncQueueModel item) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.syncQueue,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await onItemEnqueued?.call();
  }

  Future<List<SyncQueueModel>> getPendingItems({
    int limit = 100,
    int retryThreshold = 5,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseTables.syncQueue,
      where:
          '${DatabaseColumns.syncStatus} IN (?, ?, ?, ?) AND retry_count < ?',
      whereArgs: [
        'pending_create',
        'pending_update',
        'pending_delete',
        'failed',
        retryThreshold,
      ],
      orderBy: '${DatabaseColumns.createdAt} ASC',
      limit: limit,
    );
    return result.map(SyncQueueModel.fromMap).toList();
  }

  Future<void> markSynced(String queueId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.syncQueue,
      {
        DatabaseColumns.syncStatus: 'synced',
        'last_error': null,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [queueId],
    );
  }

  Future<void> markFailure({
    required String queueId,
    required int retryCount,
    required String lastError,
    required String syncStatus,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.syncQueue,
      {
        'retry_count': retryCount,
        'last_error': lastError,
        DatabaseColumns.syncStatus: syncStatus,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [queueId],
    );
  }

  Future<void> deleteById(String queueId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseTables.syncQueue,
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [queueId],
    );
  }
}
