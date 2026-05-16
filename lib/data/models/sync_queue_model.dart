import 'dart:convert';

class SyncQueueModel {
  const SyncQueueModel({
    required this.id,
    required this.businessId,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  final String id;
  final String businessId;
  final String tableName;
  final String recordId;
  final String operation;
  final Map<String, dynamic>? payload;
  final int retryCount;
  final String? lastError;
  final int createdAt;
  final int updatedAt;
  final String syncStatus;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'payload': payload == null ? null : jsonEncode(payload),
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }
}
