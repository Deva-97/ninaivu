class AppUser {
  const AppUser({
    required this.id,
    required this.businessId,
    required this.name,
    this.mobile,
    this.email,
    required this.role,
    required this.status,
    this.profileImagePath,
    this.profileImageData,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.syncStatus,
    this.createdBy,
    this.agentId,
  });

  final String id;
  final String businessId;
  final String name;
  final String? mobile;
  final String? email;
  final String role;
  final String status;
  final String? profileImagePath;
  final String? profileImageData;
  final bool profileCompleted;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String syncStatus;
  final String? createdBy;
  final String? agentId;
}
