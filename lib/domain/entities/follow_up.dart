class FollowUp {
  const FollowUp({
    required this.id,
    required this.businessId,
    required this.clientId,
    this.policyId,
    required this.followUpDateTime,
    required this.type,
    required this.status,
    this.remarks,
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
    this.clientMobile,
    this.policyNumber,
  });

  final String id;
  final String businessId;
  final String clientId;
  final String? policyId;
  final int followUpDateTime;
  final String type;
  final String status;
  final String? remarks;
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
  final String? clientMobile;
  final String? policyNumber;
}
