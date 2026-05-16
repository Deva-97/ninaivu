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

  SyncQueueModel copyWith({
    String? id,
    String? businessId,
    String? tableName,
    String? recordId,
    String? operation,
    Map<String, dynamic>? payload,
    bool clearPayload = false,
    int? retryCount,
    String? lastError,
    bool clearLastError = false,
    int? createdAt,
    int? updatedAt,
    String? syncStatus,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payload: clearPayload ? null : payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

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

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as String,
      operation: map['operation'] as String,
      payload: _decodePayload(map['payload']),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      syncStatus: map['sync_status'] as String,
    );
  }

  static Map<String, dynamic>? _decodePayload(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    return null;
  }
}
