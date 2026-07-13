part of 'database_helper.dart';

extension _DatabaseMigrations on DatabaseHelper {
  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createClientsTable(db);
    await _createPoliciesTable(db);
    await _createRemindersTable(db);
    await _createFollowUpsTable(db);
    await _createSyncQueueTable(db);
    await _createAllIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations are written cumulatively so a device can upgrade from any old
    // released version without requiring intermediate installs.
    if (oldVersion < 2) {
      await _createClientsTable(db);
      await _createPoliciesTable(db);
      await _createRemindersTable(db);
      await _createFollowUpsTable(db);
      await _createSyncQueueTable(db);
      await _createAllIndexes(db);
    }

    if (oldVersion < 3) {
      await _addColumnIfMissing(db, DatabaseTables.users, 'created_by TEXT');
      await _addColumnIfMissing(db, DatabaseTables.users, 'agent_id TEXT');
      await _createAllIndexes(db);
    }

    if (oldVersion < 4) {
      await _addColumnIfMissing(
        db,
        DatabaseTables.policies,
        "renewal_status TEXT NOT NULL DEFAULT 'Not Contacted'",
      );
      await _createAllIndexes(db);
    }

    if (oldVersion < 5) {
      await _addColumnIfMissing(
        db,
        DatabaseTables.users,
        'profile_image_path TEXT',
      );
      await _addColumnIfMissing(
        db,
        DatabaseTables.clients,
        'profile_image_path TEXT',
      );
      await _addColumnIfMissing(
        db,
        DatabaseTables.clients,
        'date_of_birth_ms INTEGER',
      );
      await _addColumnIfMissing(
        db,
        DatabaseTables.clients,
        'special_date_ms INTEGER',
      );
      await _addColumnIfMissing(
        db,
        DatabaseTables.clients,
        'special_date_label TEXT',
      );
      await _createAllIndexes(db);
    }

    if (oldVersion < 6) {
      await _createAllIndexes(db);
    }

    if (oldVersion < 7) {
      await _addColumnIfMissing(
        db,
        DatabaseTables.users,
        'profile_image_data TEXT',
      );
    }

    if (oldVersion < 8) {
      await _addColumnIfMissing(
        db,
        DatabaseTables.policies,
        '${DatabaseColumns.policyHolderName} TEXT',
      );
      await _createAllIndexes(db);
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final tableInfo = await db.rawQuery('PRAGMA table_info($table)');
    final alreadyExists = tableInfo.any((row) => row['name'] == columnName);
    if (!alreadyExists) {
      // Defensive column checks keep upgrades idempotent across development
      // builds where the same migration may be replayed more than once.
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
    }
  }
}
