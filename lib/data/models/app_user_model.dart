class AppUserModel {
  final String id;
  final String businessId;
  final String name;
  final String? mobile;
  final String? email;
  final String role;
  final String status;
  final bool profileCompleted;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String syncStatus;

  const AppUserModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.mobile,
    this.email,
    required this.role,
    required this.status,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.syncStatus,
  });

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
      profileCompleted: (map['profile_completed'] as int) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      isDeleted: (map['is_deleted'] as int) == 1,
      syncStatus: map['sync_status'] as String,
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
      status: map['status'] as String,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isDeleted: map['isDeleted'] as bool? ?? false,
      syncStatus: map['syncStatus'] as String? ?? 'synced',
    );
  }
}
