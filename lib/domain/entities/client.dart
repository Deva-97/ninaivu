class Client {
  const Client({
    required this.id,
    required this.businessId,
    required this.name,
    required this.mobile,
    this.alternateMobile,
    this.email,
    this.address,
    this.areaCity,
    this.notes,
    required this.createdBy,
    this.agentId,
    this.subAgentId,
    this.customerUserId,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.syncStatus,
    this.policyCount = 0,
  });

  final String id;
  final String businessId;
  final String name;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String? address;
  final String? areaCity;
  final String? notes;
  final String createdBy;
  final String? agentId;
  final String? subAgentId;
  final String? customerUserId;
  final String? assignedTo;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final int policyCount;
}
