class Policy {
  const Policy({
    required this.id,
    required this.businessId,
    required this.clientId,
    required this.insuranceType,
    required this.policyNumber,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.premiumAmount,
    this.paymentFrequency,
    this.vehicleNumber,
    this.vehicleModel,
    required this.status,
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
  });

  final String id;
  final String businessId;
  final String clientId;
  final String insuranceType;
  final String policyNumber;
  final String companyName;
  final int startDate;
  final int endDate;
  final double premiumAmount;
  final String? paymentFrequency;
  final String? vehicleNumber;
  final String? vehicleModel;
  final String status;
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
}
