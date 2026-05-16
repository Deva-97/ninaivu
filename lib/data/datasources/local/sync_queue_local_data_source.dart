import 'package:insurance_reminders/core/database/database_helper.dart';
import 'package:insurance_reminders/core/database/database_tables.dart';
import 'package:insurance_reminders/data/models/sync_queue_model.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueLocalDataSource {
  SyncQueueLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> enqueue(SyncQueueModel item) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.syncQueue,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
