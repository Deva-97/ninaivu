import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const String databaseName = 'ninaivu.db';
  static const int databaseVersion = 4;

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
    await _createIndex(
      db,
      'idx_users_business_id',
      DatabaseTables.users,
      DatabaseColumns.businessId,
    );
    await _createIndex(db, 'idx_users_role', DatabaseTables.users, 'role');
    await _createIndex(db, 'idx_users_mobile', DatabaseTables.users, 'mobile');
    await _createIndex(db, 'idx_users_email', DatabaseTables.users, 'email');
    await _createIndex(
      db,
      'idx_users_agent_id',
      DatabaseTables.users,
      DatabaseColumns.agentId,
    );

    await _createIndex(
      db,
      'idx_clients_business_id',
      DatabaseTables.clients,
      DatabaseColumns.businessId,
    );
    await _createIndex(
      db,
      'idx_clients_created_by',
      DatabaseTables.clients,
      DatabaseColumns.createdBy,
    );
    await _createIndex(
      db,
      'idx_clients_agent_id',
      DatabaseTables.clients,
      DatabaseColumns.agentId,
    );
    await _createIndex(db, 'idx_clients_mobile', DatabaseTables.clients, 'mobile');
    await _createIndex(db, 'idx_clients_name', DatabaseTables.clients, 'name');
    await _createIndex(
      db,
      'idx_clients_is_deleted',
      DatabaseTables.clients,
      DatabaseColumns.isDeleted,
    );
    await _createIndex(
      db,
      'idx_clients_sync_status',
      DatabaseTables.clients,
      DatabaseColumns.syncStatus,
    );

    await _createIndex(
      db,
      'idx_policies_business_id',
      DatabaseTables.policies,
      DatabaseColumns.businessId,
    );
    await _createIndex(
      db,
      'idx_policies_client_id',
      DatabaseTables.policies,
      'client_id',
    );
    await _createIndex(
      db,
      'idx_policies_created_by',
      DatabaseTables.policies,
      DatabaseColumns.createdBy,
    );
    await _createIndex(
      db,
      'idx_policies_agent_id',
      DatabaseTables.policies,
      DatabaseColumns.agentId,
    );
    await _createIndex(db, 'idx_policies_end_date', DatabaseTables.policies, 'end_date');
    await _createIndex(db, 'idx_policies_status', DatabaseTables.policies, 'status');
    await _createIndex(
      db,
      'idx_policies_renewal_status',
      DatabaseTables.policies,
      'renewal_status',
    );
    await _createIndex(
      db,
      'idx_policies_is_deleted',
      DatabaseTables.policies,
      DatabaseColumns.isDeleted,
    );
    await _createIndex(
      db,
      'idx_policies_sync_status',
      DatabaseTables.policies,
      DatabaseColumns.syncStatus,
    );

    await _createIndex(
      db,
      'idx_reminders_business_id',
      DatabaseTables.reminders,
      DatabaseColumns.businessId,
    );
    await _createIndex(
      db,
      'idx_reminders_client_id',
      DatabaseTables.reminders,
      'client_id',
    );
    await _createIndex(
      db,
      'idx_reminders_policy_id',
      DatabaseTables.reminders,
      'policy_id',
    );
    await _createIndex(
      db,
      'idx_reminders_date_time',
      DatabaseTables.reminders,
      'reminder_date_time',
    );
    await _createIndex(
      db,
      'idx_reminders_status',
      DatabaseTables.reminders,
      'status',
    );
    await _createIndex(
      db,
      'idx_reminders_notification_id',
      DatabaseTables.reminders,
      'notification_id',
    );
    await _createIndex(
      db,
      'idx_reminders_is_deleted',
      DatabaseTables.reminders,
      DatabaseColumns.isDeleted,
    );
    await _createIndex(
      db,
      'idx_reminders_sync_status',
      DatabaseTables.reminders,
      DatabaseColumns.syncStatus,
    );

    await _createIndex(
      db,
      'idx_follow_ups_business_id',
      DatabaseTables.followUps,
      DatabaseColumns.businessId,
    );
    await _createIndex(
      db,
      'idx_follow_ups_client_id',
      DatabaseTables.followUps,
      'client_id',
    );
    await _createIndex(
      db,
      'idx_follow_ups_policy_id',
      DatabaseTables.followUps,
      'policy_id',
    );
    await _createIndex(
      db,
      'idx_follow_ups_date_time',
      DatabaseTables.followUps,
      'follow_up_date_time',
    );
    await _createIndex(
      db,
      'idx_follow_ups_status',
      DatabaseTables.followUps,
      'status',
    );
    await _createIndex(
      db,
      'idx_follow_ups_created_by',
      DatabaseTables.followUps,
      DatabaseColumns.createdBy,
    );
    await _createIndex(
      db,
      'idx_follow_ups_agent_id',
      DatabaseTables.followUps,
      DatabaseColumns.agentId,
    );
    await _createIndex(
      db,
      'idx_follow_ups_is_deleted',
      DatabaseTables.followUps,
      DatabaseColumns.isDeleted,
    );
    await _createIndex(
      db,
      'idx_follow_ups_sync_status',
      DatabaseTables.followUps,
      DatabaseColumns.syncStatus,
    );

    await _createIndex(
      db,
      'idx_sync_queue_business_id',
      DatabaseTables.syncQueue,
      DatabaseColumns.businessId,
    );
    await _createIndex(
      db,
      'idx_sync_queue_table_name',
      DatabaseTables.syncQueue,
      'table_name',
    );
    await _createIndex(
      db,
      'idx_sync_queue_record_id',
      DatabaseTables.syncQueue,
      'record_id',
    );
    await _createIndex(
      db,
      'idx_sync_queue_operation',
      DatabaseTables.syncQueue,
      'operation',
    );
    await _createIndex(
      db,
      'idx_sync_queue_sync_status',
      DatabaseTables.syncQueue,
      DatabaseColumns.syncStatus,
    );
    await _createIndex(
      db,
      'idx_sync_queue_retry_count',
      DatabaseTables.syncQueue,
      'retry_count',
    );
    await _createIndex(
      db,
      'idx_sync_queue_created_at',
      DatabaseTables.syncQueue,
      DatabaseColumns.createdAt,
    );
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
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
    }
  }
}
