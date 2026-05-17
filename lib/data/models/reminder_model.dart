import 'package:ninaivu/domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.businessId,
    required super.clientId,
    required super.policyId,
    required super.reminderDateTime,
    required super.reminderType,
    required super.status,
    super.notificationId,
    required super.createdBy,
    super.agentId,
    super.subAgentId,
    super.customerUserId,
    super.assignedTo,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.syncStatus,
    super.clientName,
    super.policyNumber,
    super.companyName,
  });

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      businessId: entity.businessId,
      clientId: entity.clientId,
      policyId: entity.policyId,
      reminderDateTime: entity.reminderDateTime,
      reminderType: entity.reminderType,
      status: entity.status,
      notificationId: entity.notificationId,
      createdBy: entity.createdBy,
      agentId: entity.agentId,
      subAgentId: entity.subAgentId,
      customerUserId: entity.customerUserId,
      assignedTo: entity.assignedTo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      syncStatus: entity.syncStatus,
      clientName: entity.clientName,
      policyNumber: entity.policyNumber,
      companyName: entity.companyName,
    );
  }

  ReminderModel copyWith({
    String? id,
    String? businessId,
    String? clientId,
    String? policyId,
    int? reminderDateTime,
    String? reminderType,
    String? status,
    int? notificationId,
    bool clearNotificationId = false,
    String? createdBy,
    String? agentId,
    String? subAgentId,
    String? customerUserId,
    String? assignedTo,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    String? syncStatus,
    String? clientName,
    String? policyNumber,
    String? companyName,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      clientId: clientId ?? this.clientId,
      policyId: policyId ?? this.policyId,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      reminderType: reminderType ?? this.reminderType,
      status: status ?? this.status,
      notificationId: clearNotificationId
          ? null
          : notificationId ?? this.notificationId,
      createdBy: createdBy ?? this.createdBy,
      agentId: agentId ?? this.agentId,
      subAgentId: subAgentId ?? this.subAgentId,
      customerUserId: customerUserId ?? this.customerUserId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      clientName: clientName ?? this.clientName,
      policyNumber: policyNumber ?? this.policyNumber,
      companyName: companyName ?? this.companyName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'client_id': clientId,
      'policy_id': policyId,
      'reminder_date_time': reminderDateTime,
      'reminder_type': reminderType,
      'status': status,
      'notification_id': notificationId,
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

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      clientId: map['client_id'] as String,
      policyId: map['policy_id'] as String,
      reminderDateTime: map['reminder_date_time'] as int,
      reminderType: map['reminder_type'] as String,
      status: map['status'] as String,
      notificationId: map['notification_id'] as int?,
      createdBy: map['created_by'] as String,
      agentId: map['agent_id'] as String?,
      subAgentId: map['sub_agent_id'] as String?,
      customerUserId: map['customer_user_id'] as String?,
      assignedTo: map['assigned_to'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      clientName: map['client_name'] as String?,
      policyNumber: map['policy_number'] as String?,
      companyName: map['company_name'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'businessId': businessId,
      'clientId': clientId,
      'policyId': policyId,
      'reminderDateTime': reminderDateTime,
      'reminderType': reminderType,
      'status': status,
      'notificationId': notificationId,
      'createdBy': createdBy,
      'agentId': agentId,
      'subAgentId': subAgentId,
      'customerUserId': customerUserId,
      'assignedTo': assignedTo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'syncStatus': syncStatus,
      'clientName': clientName,
      'policyNumber': policyNumber,
      'companyName': companyName,
    };
  }

  factory ReminderModel.fromFirestore(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      businessId: map['businessId'] as String,
      clientId: map['clientId'] as String,
      policyId: map['policyId'] as String,
      reminderDateTime: map['reminderDateTime'] as int,
      reminderType: map['reminderType'] as String,
      status: map['status'] as String,
      notificationId: map['notificationId'] as int?,
      createdBy: map['createdBy'] as String,
      agentId: map['agentId'] as String?,
      subAgentId: map['subAgentId'] as String?,
      customerUserId: map['customerUserId'] as String?,
      assignedTo: map['assignedTo'] as String?,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isDeleted: map['isDeleted'] as bool? ?? false,
      syncStatus: map['syncStatus'] as String? ?? 'synced',
      clientName: map['clientName'] as String?,
      policyNumber: map['policyNumber'] as String?,
      companyName: map['companyName'] as String?,
    );
  }
}
