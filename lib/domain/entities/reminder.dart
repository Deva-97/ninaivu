class Reminder {
  const Reminder({
    required this.id,
    required this.businessId,
    required this.clientId,
    required this.policyId,
    required this.reminderDateTime,
    required this.reminderType,
    required this.status,
    this.notificationId,
    required this.createdBy,
    this.agentId,
    this.subAgentId,
    this.customerUserId,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.syncStatus,
    this.clientName,
    this.policyNumber,
    this.companyName,
  });

  final String id;
  final String businessId;
  final String clientId;
  final String policyId;
  final int reminderDateTime;
  final String reminderType;
  final String status;
  final int? notificationId;
  final String createdBy;
  final String? agentId;
  final String? subAgentId;
  final String? customerUserId;
  final String? assignedTo;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final String? clientName;
  final String? policyNumber;
  final String? companyName;
}
