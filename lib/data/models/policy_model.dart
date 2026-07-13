import 'package:ninaivu/domain/entities/policy.dart';

class PolicyModel extends Policy {
  const PolicyModel({
    required super.id,
    required super.businessId,
    required super.clientId,
    required super.insuranceType,
    required super.policyNumber,
    super.policyHolderName,
    required super.companyName,
    required super.startDate,
    required super.endDate,
    required super.premiumAmount,
    super.paymentFrequency,
    super.vehicleNumber,
    super.vehicleModel,
    required super.status,
    required super.renewalStatus,
    super.notes,
    required super.createdBy,
    super.agentId,
    super.subAgentId,
    super.customerUserId,
    super.assignedTo,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.syncStatus,
  });

  factory PolicyModel.fromEntity(Policy entity) {
    return PolicyModel(
      id: entity.id,
      businessId: entity.businessId,
      clientId: entity.clientId,
      insuranceType: entity.insuranceType,
      policyNumber: entity.policyNumber,
      policyHolderName: entity.policyHolderName,
      companyName: entity.companyName,
      startDate: entity.startDate,
      endDate: entity.endDate,
      premiumAmount: entity.premiumAmount,
      paymentFrequency: entity.paymentFrequency,
      vehicleNumber: entity.vehicleNumber,
      vehicleModel: entity.vehicleModel,
      status: entity.status,
      renewalStatus: entity.renewalStatus,
      notes: entity.notes,
      createdBy: entity.createdBy,
      agentId: entity.agentId,
      subAgentId: entity.subAgentId,
      customerUserId: entity.customerUserId,
      assignedTo: entity.assignedTo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      syncStatus: entity.syncStatus,
    );
  }

  PolicyModel copyWith({
    String? id,
    String? businessId,
    String? clientId,
    String? insuranceType,
    String? policyNumber,
    String? policyHolderName,
    String? companyName,
    int? startDate,
    int? endDate,
    double? premiumAmount,
    String? paymentFrequency,
    String? vehicleNumber,
    String? vehicleModel,
    String? status,
    String? renewalStatus,
    String? notes,
    String? createdBy,
    String? agentId,
    String? subAgentId,
    String? customerUserId,
    String? assignedTo,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return PolicyModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      clientId: clientId ?? this.clientId,
      insuranceType: insuranceType ?? this.insuranceType,
      policyNumber: policyNumber ?? this.policyNumber,
      policyHolderName: policyHolderName ?? this.policyHolderName,
      companyName: companyName ?? this.companyName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      status: status ?? this.status,
      renewalStatus: renewalStatus ?? this.renewalStatus,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      agentId: agentId ?? this.agentId,
      subAgentId: subAgentId ?? this.subAgentId,
      customerUserId: customerUserId ?? this.customerUserId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'client_id': clientId,
      'insurance_type': insuranceType,
      'policy_number': policyNumber,
      'policy_holder_name': policyHolderName,
      'company_name': companyName,
      'start_date': startDate,
      'end_date': endDate,
      'premium_amount': premiumAmount,
      'payment_frequency': paymentFrequency,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
      'status': status,
      'renewal_status': renewalStatus,
      'notes': notes,
      'created_by': createdBy,
      'agent_id': agentId,
      'sub_agent_id': subAgentId,
      'customer_user_id': customerUserId,
      'assigned_to': assignedTo,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory PolicyModel.fromMap(Map<String, dynamic> map) {
    return PolicyModel(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      clientId: map['client_id'] as String,
      insuranceType: map['insurance_type'] as String,
      policyNumber: map['policy_number'] as String,
      policyHolderName: map['policy_holder_name'] as String?,
      companyName: map['company_name'] as String,
      startDate: map['start_date'] as int,
      endDate: map['end_date'] as int,
      premiumAmount: (map['premium_amount'] as num).toDouble(),
      paymentFrequency: map['payment_frequency'] as String?,
      vehicleNumber: map['vehicle_number'] as String?,
      vehicleModel: map['vehicle_model'] as String?,
      status: map['status'] as String,
      renewalStatus:
          map['renewal_status'] as String? ??
          _defaultRenewalStatus(map['status'] as String?),
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String,
      agentId: map['agent_id'] as String?,
      subAgentId: map['sub_agent_id'] as String?,
      customerUserId: map['customer_user_id'] as String?,
      assignedTo: map['assigned_to'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'businessId': businessId,
      'clientId': clientId,
      'insuranceType': insuranceType,
      'policyNumber': policyNumber,
      'policyHolderName': policyHolderName,
      'companyName': companyName,
      'startDate': startDate,
      'endDate': endDate,
      'premiumAmount': premiumAmount,
      'paymentFrequency': paymentFrequency,
      'vehicleNumber': vehicleNumber,
      'vehicleModel': vehicleModel,
      'status': status,
      'renewalStatus': renewalStatus,
      'notes': notes,
      'createdBy': createdBy,
      'agentId': agentId,
      'subAgentId': subAgentId,
      'customerUserId': customerUserId,
      'assignedTo': assignedTo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'syncStatus': syncStatus,
    };
  }

  factory PolicyModel.fromFirestore(Map<String, dynamic> map) {
    return PolicyModel(
      id: map['id'] as String,
      businessId: map['businessId'] as String,
      clientId: map['clientId'] as String,
      insuranceType: map['insuranceType'] as String,
      policyNumber: map['policyNumber'] as String,
      policyHolderName: map['policyHolderName'] as String?,
      companyName: map['companyName'] as String,
      startDate: map['startDate'] as int,
      endDate: map['endDate'] as int,
      premiumAmount: (map['premiumAmount'] as num).toDouble(),
      paymentFrequency: map['paymentFrequency'] as String?,
      vehicleNumber: map['vehicleNumber'] as String?,
      vehicleModel: map['vehicleModel'] as String?,
      status: map['status'] as String,
      renewalStatus:
          map['renewalStatus'] as String? ??
          _defaultRenewalStatus(map['status'] as String?),
      notes: map['notes'] as String?,
      createdBy: map['createdBy'] as String,
      agentId: map['agentId'] as String?,
      subAgentId: map['subAgentId'] as String?,
      customerUserId: map['customerUserId'] as String?,
      assignedTo: map['assignedTo'] as String?,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isDeleted: map['isDeleted'] as bool? ?? false,
      syncStatus: map['syncStatus'] as String? ?? 'synced',
    );
  }

  // Default renewal stage for older records that do not have the new column yet.
  static String _defaultRenewalStatus(String? policyStatus) {
    if ((policyStatus ?? '').trim().toLowerCase() == 'renewed') {
      return 'Renewed';
    }
    return 'Not Contacted';
  }
}
