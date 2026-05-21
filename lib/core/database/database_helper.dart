import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

typedef _IndexSpec = ({String name, String table, String column});

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
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.users} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        name TEXT NOT NULL,
        mobile TEXT,
        email TEXT,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        profile_image_path TEXT,
        profile_image_data TEXT,
        profile_completed INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.isDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL,
        ${DatabaseColumns.createdBy} TEXT,
        ${DatabaseColumns.agentId} TEXT
      )
    ''');
  }

  Future<void> _createClientsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.clients} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        name TEXT NOT NULL,
        mobile TEXT NOT NULL,
        alternate_mobile TEXT,
        email TEXT,
        address TEXT,
        area_city TEXT,
        notes TEXT,
        profile_image_path TEXT,
        date_of_birth_ms INTEGER,
        special_date_ms INTEGER,
        special_date_label TEXT,
        ${DatabaseColumns.createdBy} TEXT NOT NULL,
        ${DatabaseColumns.agentId} TEXT,
        ${DatabaseColumns.subAgentId} TEXT,
        ${DatabaseColumns.customerUserId} TEXT,
        ${DatabaseColumns.assignedTo} TEXT,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.isDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPoliciesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.policies} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        client_id TEXT NOT NULL,
        insurance_type TEXT NOT NULL,
        policy_number TEXT NOT NULL,
        company_name TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        premium_amount REAL NOT NULL,
        payment_frequency TEXT,
        vehicle_number TEXT,
        vehicle_model TEXT,
        status TEXT NOT NULL,
        renewal_status TEXT NOT NULL DEFAULT 'Not Contacted',
        notes TEXT,
        ${DatabaseColumns.createdBy} TEXT NOT NULL,
        ${DatabaseColumns.agentId} TEXT,
        ${DatabaseColumns.subAgentId} TEXT,
        ${DatabaseColumns.customerUserId} TEXT,
        ${DatabaseColumns.assignedTo} TEXT,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.isDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.reminders} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        client_id TEXT NOT NULL,
        policy_id TEXT NOT NULL,
        reminder_date_time INTEGER NOT NULL,
        reminder_type TEXT NOT NULL,
        status TEXT NOT NULL,
        notification_id INTEGER,
        ${DatabaseColumns.createdBy} TEXT NOT NULL,
        ${DatabaseColumns.agentId} TEXT,
        ${DatabaseColumns.subAgentId} TEXT,
        ${DatabaseColumns.customerUserId} TEXT,
        ${DatabaseColumns.assignedTo} TEXT,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.isDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createFollowUpsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.followUps} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        client_id TEXT NOT NULL,
        policy_id TEXT,
        follow_up_date_time INTEGER NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT,
        ${DatabaseColumns.createdBy} TEXT NOT NULL,
        ${DatabaseColumns.agentId} TEXT,
        ${DatabaseColumns.subAgentId} TEXT,
        ${DatabaseColumns.customerUserId} TEXT,
        ${DatabaseColumns.assignedTo} TEXT,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.isDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSyncQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.syncQueue} (
        ${DatabaseColumns.id} TEXT PRIMARY KEY,
        ${DatabaseColumns.businessId} TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        ${DatabaseColumns.createdAt} INTEGER NOT NULL,
        ${DatabaseColumns.updatedAt} INTEGER NOT NULL,
        ${DatabaseColumns.syncStatus} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAllIndexes(Database db) async {
    for (final spec in _indexSpecs) {
      await _createIndex(db, spec.name, spec.table, spec.column);
    }
    for (final statement in _compoundIndexStatements) {
      await db.execute(statement);
    }
  }

  Future<void> _createIndex(
    Database db,
    String indexName,
    String tableName,
    String columnName,
  ) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS $indexName ON $tableName($columnName)',
    );
  }

  Future<void> _addColumnIfMissing(Database db, String table, String columnDefinition) async {
    final columnName = columnDefinition.split(' ').first;
    final tableInfo = await db.rawQuery('PRAGMA table_info($table)');
    final alreadyExists = tableInfo.any((row) => row['name'] == columnName);
    if (!alreadyExists) {
      // Defensive column checks keep upgrades idempotent across development
      // builds where the same migration may be replayed more than once.
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
    }
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

  static const List<_IndexSpec> _indexSpecs = [
    (
      name: 'idx_users_business_id',
      table: DatabaseTables.users,
      column: DatabaseColumns.businessId,
    ),
    (name: 'idx_users_role', table: DatabaseTables.users, column: 'role'),
    (name: 'idx_users_name', table: DatabaseTables.users, column: 'name'),
    (name: 'idx_users_mobile', table: DatabaseTables.users, column: 'mobile'),
    (name: 'idx_users_email', table: DatabaseTables.users, column: 'email'),
    (
      name: 'idx_users_agent_id',
      table: DatabaseTables.users,
      column: DatabaseColumns.agentId,
    ),
    (
      name: 'idx_clients_business_id',
      table: DatabaseTables.clients,
      column: DatabaseColumns.businessId,
    ),
    (
      name: 'idx_clients_created_by',
      table: DatabaseTables.clients,
      column: DatabaseColumns.createdBy,
    ),
    (
      name: 'idx_clients_agent_id',
      table: DatabaseTables.clients,
      column: DatabaseColumns.agentId,
    ),
    (name: 'idx_clients_mobile', table: DatabaseTables.clients, column: 'mobile'),
    (name: 'idx_clients_name', table: DatabaseTables.clients, column: 'name'),
    (
      name: 'idx_clients_is_deleted',
      table: DatabaseTables.clients,
      column: DatabaseColumns.isDeleted,
    ),
    (
      name: 'idx_clients_sync_status',
      table: DatabaseTables.clients,
      column: DatabaseColumns.syncStatus,
    ),
    (
      name: 'idx_policies_business_id',
      table: DatabaseTables.policies,
      column: DatabaseColumns.businessId,
    ),
    (name: 'idx_policies_client_id', table: DatabaseTables.policies, column: 'client_id'),
    (
      name: 'idx_policies_created_by',
      table: DatabaseTables.policies,
      column: DatabaseColumns.createdBy,
    ),
    (
      name: 'idx_policies_agent_id',
      table: DatabaseTables.policies,
      column: DatabaseColumns.agentId,
    ),
    (
      name: 'idx_policies_policy_number',
      table: DatabaseTables.policies,
      column: 'policy_number',
    ),
    (
      name: 'idx_policies_vehicle_number',
      table: DatabaseTables.policies,
      column: 'vehicle_number',
    ),
    (name: 'idx_policies_end_date', table: DatabaseTables.policies, column: 'end_date'),
    (name: 'idx_policies_status', table: DatabaseTables.policies, column: 'status'),
    (
      name: 'idx_policies_renewal_status',
      table: DatabaseTables.policies,
      column: 'renewal_status',
    ),
    (
      name: 'idx_policies_is_deleted',
      table: DatabaseTables.policies,
      column: DatabaseColumns.isDeleted,
    ),
    (
      name: 'idx_policies_sync_status',
      table: DatabaseTables.policies,
      column: DatabaseColumns.syncStatus,
    ),
    (
      name: 'idx_reminders_business_id',
      table: DatabaseTables.reminders,
      column: DatabaseColumns.businessId,
    ),
    (name: 'idx_reminders_client_id', table: DatabaseTables.reminders, column: 'client_id'),
    (name: 'idx_reminders_policy_id', table: DatabaseTables.reminders, column: 'policy_id'),
    (
      name: 'idx_reminders_date_time',
      table: DatabaseTables.reminders,
      column: 'reminder_date_time',
    ),
    (name: 'idx_reminders_status', table: DatabaseTables.reminders, column: 'status'),
    (
      name: 'idx_reminders_notification_id',
      table: DatabaseTables.reminders,
      column: 'notification_id',
    ),
    (
      name: 'idx_reminders_is_deleted',
      table: DatabaseTables.reminders,
      column: DatabaseColumns.isDeleted,
    ),
    (
      name: 'idx_reminders_sync_status',
      table: DatabaseTables.reminders,
      column: DatabaseColumns.syncStatus,
    ),
    (
      name: 'idx_follow_ups_business_id',
      table: DatabaseTables.followUps,
      column: DatabaseColumns.businessId,
    ),
    (name: 'idx_follow_ups_client_id', table: DatabaseTables.followUps, column: 'client_id'),
    (name: 'idx_follow_ups_policy_id', table: DatabaseTables.followUps, column: 'policy_id'),
    (
      name: 'idx_follow_ups_date_time',
      table: DatabaseTables.followUps,
      column: 'follow_up_date_time',
    ),
    (name: 'idx_follow_ups_status', table: DatabaseTables.followUps, column: 'status'),
    (
      name: 'idx_follow_ups_created_by',
      table: DatabaseTables.followUps,
      column: DatabaseColumns.createdBy,
    ),
    (
      name: 'idx_follow_ups_agent_id',
      table: DatabaseTables.followUps,
      column: DatabaseColumns.agentId,
    ),
    (
      name: 'idx_follow_ups_is_deleted',
      table: DatabaseTables.followUps,
      column: DatabaseColumns.isDeleted,
    ),
    (
      name: 'idx_follow_ups_sync_status',
      table: DatabaseTables.followUps,
      column: DatabaseColumns.syncStatus,
    ),
    (
      name: 'idx_sync_queue_business_id',
      table: DatabaseTables.syncQueue,
      column: DatabaseColumns.businessId,
    ),
    (
      name: 'idx_sync_queue_table_name',
      table: DatabaseTables.syncQueue,
      column: 'table_name',
    ),
    (
      name: 'idx_sync_queue_record_id',
      table: DatabaseTables.syncQueue,
      column: 'record_id',
    ),
    (
      name: 'idx_sync_queue_operation',
      table: DatabaseTables.syncQueue,
      column: 'operation',
    ),
    (
      name: 'idx_sync_queue_sync_status',
      table: DatabaseTables.syncQueue,
      column: DatabaseColumns.syncStatus,
    ),
    (
      name: 'idx_sync_queue_retry_count',
      table: DatabaseTables.syncQueue,
      column: 'retry_count',
    ),
    (
      name: 'idx_sync_queue_created_at',
      table: DatabaseTables.syncQueue,
      column: DatabaseColumns.createdAt,
    ),
  ];

  static const List<String> _compoundIndexStatements = [
    'CREATE INDEX IF NOT EXISTS idx_clients_business_deleted_updated '
        'ON ${DatabaseTables.clients}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.updatedAt} DESC'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_clients_business_deleted_assigned '
        'ON ${DatabaseTables.clients}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.assignedTo}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_policies_business_deleted_end_date '
        'ON ${DatabaseTables.policies}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, end_date'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_policies_business_deleted_updated '
        'ON ${DatabaseTables.policies}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.updatedAt} DESC'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_policies_business_client_deleted '
        'ON ${DatabaseTables.policies}('
        '${DatabaseColumns.businessId}, client_id, ${DatabaseColumns.isDeleted}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_policies_business_deleted_assigned '
        'ON ${DatabaseTables.policies}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.assignedTo}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_reminders_business_deleted_date '
        'ON ${DatabaseTables.reminders}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, reminder_date_time'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_reminders_business_status_deleted '
        'ON ${DatabaseTables.reminders}('
        '${DatabaseColumns.businessId}, status, ${DatabaseColumns.isDeleted}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_reminders_business_deleted_assigned '
        'ON ${DatabaseTables.reminders}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.assignedTo}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_follow_ups_business_deleted_date '
        'ON ${DatabaseTables.followUps}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, follow_up_date_time'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_follow_ups_business_status_deleted '
        'ON ${DatabaseTables.followUps}('
        '${DatabaseColumns.businessId}, status, ${DatabaseColumns.isDeleted}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_follow_ups_business_deleted_assigned '
        'ON ${DatabaseTables.followUps}('
        '${DatabaseColumns.businessId}, ${DatabaseColumns.isDeleted}, ${DatabaseColumns.assignedTo}'
        ')',
    'CREATE INDEX IF NOT EXISTS idx_sync_queue_status_retry_created '
        'ON ${DatabaseTables.syncQueue}('
        '${DatabaseColumns.syncStatus}, retry_count, ${DatabaseColumns.createdAt}'
        ')',
  ];
}
