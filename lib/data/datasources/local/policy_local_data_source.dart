import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/models/policy_model.dart';
import 'package:sqflite/sqflite.dart';

class PolicyLocalDataSource {
  PolicyLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> insertPolicy(PolicyModel policy) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.policies,
      policy.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePolicy(PolicyModel policy) => insertPolicy(policy);

  Future<void> softDeletePolicy(String policyId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.policies,
      {
        DatabaseColumns.isDeleted: 1,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_delete',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [policyId],
    );
  }

  Future<PolicyModel?> getPolicyById(String policyId) async {
    return _getPolicyById(policyId, includeDeleted: false);
  }

  Future<PolicyModel?> getPolicyByIdIncludingDeleted(String policyId) async {
    return _getPolicyById(policyId, includeDeleted: true);
  }

  Future<PolicyModel?> _getPolicyById(
    String policyId, {
    required bool includeDeleted,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseTables.policies,
      where: includeDeleted
          ? '${DatabaseColumns.id} = ?'
          : '${DatabaseColumns.id} = ? AND ${DatabaseColumns.isDeleted} = 0',
      whereArgs: [policyId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return PolicyModel.fromMap(result.first);
  }

  Future<void> markPolicySynced(String policyId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.policies,
      {
        DatabaseColumns.syncStatus: 'synced',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [policyId],
    );
  }

  Future<List<PolicyModel>> getPoliciesForAdmin({
    required String businessId,
    String? query,
    int limit = 50,
    int offset = 0,
  }) {
    return _getPolicies(
      whereClauses: [
        '${DatabaseColumns.businessId} = ?',
        '${DatabaseColumns.isDeleted} = 0',
      ],
      whereArgs: [businessId],
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<PolicyModel>> getPoliciesForAgent({
    required String businessId,
    required String userId,
    String? query,
    int limit = 50,
    int offset = 0,
  }) {
    return _getPolicies(
      whereClauses: [
        '${DatabaseColumns.businessId} = ?',
        '${DatabaseColumns.isDeleted} = 0',
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)',
      ],
      whereArgs: [businessId, userId, userId],
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<PolicyModel>> getPoliciesByClient(String clientId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseTables.policies,
      where: 'client_id = ? AND ${DatabaseColumns.isDeleted} = 0',
      whereArgs: [clientId],
      orderBy: 'end_date ASC',
    );
    return result.map(PolicyModel.fromMap).toList();
  }

  Future<List<PolicyModel>> searchPolicies({
    required String businessId,
    required bool isAdmin,
    required String userId,
    required String query,
    String? clientId,
    int limit = 50,
  }) {
    final clauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      '${DatabaseColumns.isDeleted} = 0',
      '(policy_number LIKE ? OR company_name LIKE ? OR insurance_type LIKE ? OR vehicle_number LIKE ?)',
    ];
    final pattern = '%${query.trim()}%';
    final args = <Object?>[businessId, pattern, pattern, pattern, pattern];
    if (clientId != null && clientId.isNotEmpty) {
      clauses.add('client_id = ?');
      args.add(clientId);
    }
    if (!isAdmin) {
      clauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)',
      );
      args.addAll([userId, userId, userId]);
    }

    return _getPolicies(
      whereClauses: clauses,
      whereArgs: args,
      limit: limit,
      offset: 0,
    );
  }

  Future<PolicyModel?> findPolicyByNumber({
    required String businessId,
    required String policyNumber,
    required bool isAdmin,
    required String userId,
  }) async {
    final db = await _databaseHelper.database;
    final whereClauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      'policy_number = ?',
      '${DatabaseColumns.isDeleted} = 0',
    ];
    final args = <Object?>[businessId, policyNumber];
    if (!isAdmin) {
      whereClauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)',
      );
      args.addAll([userId, userId, userId]);
    }

    final result = await db.query(
      DatabaseTables.policies,
      where: whereClauses.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return PolicyModel.fromMap(result.first);
  }

  Future<void> updateRenewalStatus({
    required String policyId,
    required String renewalStatus,
    String? policyStatus,
  }) async {
    final db = await _databaseHelper.database;
    final values = <String, Object?>{
      'renewal_status': renewalStatus,
      DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      DatabaseColumns.syncStatus: 'pending_update',
    };
    if (policyStatus != null && policyStatus.isNotEmpty) {
      values['status'] = policyStatus;
    }
    await db.update(
      DatabaseTables.policies,
      values,
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [policyId],
    );
  }

  Future<List<PolicyModel>> getExpiringPolicies({
    required String businessId,
    required bool isAdmin,
    required String userId,
    int withinDays = 30,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = now
        .add(Duration(days: withinDays))
        .millisecondsSinceEpoch;

    final clauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      '${DatabaseColumns.isDeleted} = 0',
      'end_date BETWEEN ? AND ?',
    ];
    final args = <Object?>[businessId, start, end];
    if (!isAdmin) {
      clauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)',
      );
      args.addAll([userId, userId]);
    }

    return _getPolicies(
      whereClauses: clauses,
      whereArgs: args,
      limit: 200,
      offset: 0,
    );
  }

  Future<List<PolicyModel>> getExpiredPolicies({
    required String businessId,
    required bool isAdmin,
    required String userId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final clauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      '${DatabaseColumns.isDeleted} = 0',
      'end_date < ?',
    ];
    final args = <Object?>[businessId, now];
    if (!isAdmin) {
      clauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)',
      );
      args.addAll([userId, userId]);
    }

    return _getPolicies(
      whereClauses: clauses,
      whereArgs: args,
      limit: 200,
      offset: 0,
    );
  }

  Future<List<PolicyModel>> _getPolicies({
    required List<String> whereClauses,
    required List<Object?> whereArgs,
    String? query,
    required int limit,
    required int offset,
  }) async {
    final db = await _databaseHelper.database;
    final clauses = [...whereClauses];
    final args = [...whereArgs];
    if (query != null && query.trim().isNotEmpty) {
      clauses.add(
        '(policy_number LIKE ? OR company_name LIKE ? OR insurance_type LIKE ? OR vehicle_number LIKE ?)',
      );
      final pattern = '%${query.trim()}%';
      args.addAll([pattern, pattern, pattern, pattern]);
    }

    final result = await db.query(
      DatabaseTables.policies,
      where: clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'end_date ASC',
      limit: limit,
      offset: offset,
    );
    return result.map(PolicyModel.fromMap).toList();
  }
}
