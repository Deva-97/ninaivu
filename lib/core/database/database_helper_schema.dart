part of 'database_helper.dart';

extension _DatabaseSchema on DatabaseHelper {
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
}
