import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

part 'database_helper_indexes.dart';
part 'database_helper_migrations.dart';
part 'database_helper_schema.dart';

/// Owns the local SQLite schema used by the offline-first data layer.
///
/// Repositories and local data sources should treat this as the single source
/// of truth for table creation, indexes, and migrations.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const String databaseName = 'ninaivu.db';
  static const int databaseVersion = 7;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> clearLocalBusinessData() async {
    final db = await database;
    // User session rows are intentionally preserved so the device can stay
    // signed in while clearing only business records and pending sync entries.
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.reminders);
      await txn.delete(DatabaseTables.followUps);
      await txn.delete(DatabaseTables.policies);
      await txn.delete(DatabaseTables.clients);
      await txn.delete(DatabaseTables.syncQueue);
    });
  }
}
