class DatabaseTables {
  DatabaseTables._();

  static const String users = 'users';
  static const String clients = 'clients';
  static const String policies = 'policies';
  static const String reminders = 'reminders';
  static const String followUps = 'follow_ups';
  static const String syncQueue = 'sync_queue';
}

class DatabaseColumns {
  DatabaseColumns._();

  static const String id = 'id';
  static const String businessId = 'business_id';
  static const String policyHolderName = 'policy_holder_name';
  static const String createdBy = 'created_by';
  static const String agentId = 'agent_id';
  static const String subAgentId = 'sub_agent_id';
  static const String customerUserId = 'customer_user_id';
  static const String assignedTo = 'assigned_to';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isDeleted = 'is_deleted';
  static const String syncStatus = 'sync_status';
}
