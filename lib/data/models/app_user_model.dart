import 'package:ninaivu/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.businessId,
    required super.name,
    super.mobile,
    super.email,
    required super.role,
    required super.status,
    required super.profileCompleted,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.syncStatus,
    super.createdBy,
    super.agentId,
  });

  factory AppUserModel.fromEntity(AppUser entity) {
    return AppUserModel(
      id: entity.id,
      businessId: entity.businessId,
      name: entity.name,
      mobile: entity.mobile,
      email: entity.email,
      role: entity.role,
      status: entity.status,
      profileCompleted: entity.profileCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      syncStatus: entity.syncStatus,
      createdBy: entity.createdBy,
      agentId: entity.agentId,
    );
  }

  AppUserModel copyWith({
    String? id,
    String? businessId,
    String? name,
    String? mobile,
    String? email,
    String? role,
    String? status,
    bool? profileCompleted,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    String? syncStatus,
    String? createdBy,
    String? agentId,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      createdBy: createdBy ?? this.createdBy,
      agentId: agentId ?? this.agentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'role': role,
      'status': status,
      'profile_completed': profileCompleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
      'created_by': createdBy,
      'agent_id': agentId,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String,
      status: map['status'] as String,
      profileCompleted: (map['profile_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdBy: map['created_by'] as String?,
      agentId: map['agent_id'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'role': role,
      'status': status,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'syncStatus': syncStatus,
      'createdBy': createdBy,
      'agentId': agentId,
    };
  }

  factory AppUserModel.fromFirestore(Map<String, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      businessId: map['businessId'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String,
      status: map['status'] as String? ?? 'active',
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isDeleted: map['isDeleted'] as bool? ?? false,
      syncStatus: map['syncStatus'] as String? ?? 'synced',
      createdBy: map['createdBy'] as String?,
      agentId: map['agentId'] as String?,
    );
  }
}
