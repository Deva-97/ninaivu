part of 'database_helper.dart';

typedef _IndexSpec = ({String name, String table, String column});

extension _DatabaseIndexes on DatabaseHelper {
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
}

const List<_IndexSpec> _indexSpecs = [
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
  (
    name: 'idx_policies_client_id',
    table: DatabaseTables.policies,
    column: 'client_id',
  ),
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
  (
    name: 'idx_policies_end_date',
    table: DatabaseTables.policies,
    column: 'end_date',
  ),
  (
    name: 'idx_policies_status',
    table: DatabaseTables.policies,
    column: 'status',
  ),
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
  (
    name: 'idx_reminders_client_id',
    table: DatabaseTables.reminders,
    column: 'client_id',
  ),
  (
    name: 'idx_reminders_policy_id',
    table: DatabaseTables.reminders,
    column: 'policy_id',
  ),
  (
    name: 'idx_reminders_date_time',
    table: DatabaseTables.reminders,
    column: 'reminder_date_time',
  ),
  (
    name: 'idx_reminders_status',
    table: DatabaseTables.reminders,
    column: 'status',
  ),
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
  (
    name: 'idx_follow_ups_client_id',
    table: DatabaseTables.followUps,
    column: 'client_id',
  ),
  (
    name: 'idx_follow_ups_policy_id',
    table: DatabaseTables.followUps,
    column: 'policy_id',
  ),
  (
    name: 'idx_follow_ups_date_time',
    table: DatabaseTables.followUps,
    column: 'follow_up_date_time',
  ),
  (
    name: 'idx_follow_ups_status',
    table: DatabaseTables.followUps,
    column: 'status',
  ),
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

const List<String> _compoundIndexStatements = [
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
