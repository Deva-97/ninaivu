import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/utils/follow_up_status_helper.dart';
import 'package:ninaivu/data/models/follow_up_model.dart';
import 'package:sqflite/sqflite.dart';

class FollowUpLocalDataSource {
  FollowUpLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> insertFollowUp(FollowUpModel followUp) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.followUps,
      followUp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFollowUp(FollowUpModel followUp) => insertFollowUp(followUp);

  Future<void> softDeleteFollowUp(String followUpId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.followUps,
      {
        DatabaseColumns.isDeleted: 1,
        'status': 'Cancelled',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_delete',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [followUpId],
    );
  }

  Future<FollowUpModel?> getFollowUpById(String followUpId) async {
    await markPendingPastFollowUpsAsMissed();
    return _getFollowUpById(followUpId, includeDeleted: false);
  }

  Future<FollowUpModel?> getFollowUpByIdIncludingDeleted(String followUpId) async {
    return _getFollowUpById(followUpId, includeDeleted: true);
  }

  Future<FollowUpModel?> _getFollowUpById(
    String followUpId, {
    required bool includeDeleted,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      _baseFollowUpQuery(
        whereClause: includeDeleted
            ? 'f.${DatabaseColumns.id} = ?'
            : 'f.${DatabaseColumns.id} = ? AND f.${DatabaseColumns.isDeleted} = 0',
      ),
      [followUpId],
    );

    if (result.isEmpty) {
      return null;
    }

    return FollowUpModel.fromMap(result.first);
  }

  Future<void> markFollowUpSynced(String followUpId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.followUps,
      {
        DatabaseColumns.syncStatus: 'synced',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [followUpId],
    );
  }

  Future<List<FollowUpModel>> getFollowUps({
    required String businessId,
    required bool isAdmin,
    required String userId,
    String filter = 'today',
    int withinDays = 30,
  }) async {
    await markPendingPastFollowUpsAsMissed();
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startMs = startOfToday.millisecondsSinceEpoch;
    final endOfToday = startOfToday
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    final endRange = startOfToday
        .add(Duration(days: withinDays + 1))
        .millisecondsSinceEpoch;

    final whereClauses = <String>[
      'f.${DatabaseColumns.businessId} = ?',
      'f.${DatabaseColumns.isDeleted} = 0',
    ];
    final args = <Object?>[businessId];

    if (!isAdmin) {
      whereClauses.add(
        '(f.${DatabaseColumns.createdBy} = ? OR f.${DatabaseColumns.agentId} = ? OR f.${DatabaseColumns.assignedTo} = ?)',
      );
      args.addAll([userId, userId, userId]);
    }

    switch (filter.trim().toLowerCase()) {
      case 'today':
        whereClauses.add(
          'f.follow_up_date_time >= ? AND f.follow_up_date_time < ?',
        );
        args.addAll([startMs, endOfToday]);
        break;
      case 'missed':
        whereClauses.add("f.status = 'Missed'");
        break;
      case 'completed':
        whereClauses.add("f.status = 'Completed'");
        break;
      case 'upcoming':
        whereClauses.add(
          "f.status = 'Pending' AND f.follow_up_date_time >= ? AND f.follow_up_date_time < ?",
        );
        args.addAll([DateTime.now().millisecondsSinceEpoch, endRange]);
        break;
      default:
        break;
    }

    final result = await db.rawQuery(
      _baseFollowUpQuery(whereClause: whereClauses.join(' AND ')),
      args,
    );
    return result.map(FollowUpModel.fromMap).toList();
  }

  Future<void> markFollowUpCompleted(String followUpId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.followUps,
      {
        'status': 'Completed',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [followUpId],
    );
  }

  Future<void> rescheduleFollowUp({
    required String followUpId,
    required int scheduledAt,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.followUps,
      {
        'follow_up_date_time': scheduledAt,
        'status': 'Pending',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [followUpId],
    );
  }

  Future<List<FollowUpModel>> getFollowUpsByClient(
    String clientId, {
    String? filter,
  }) async {
    await markPendingPastFollowUpsAsMissed();
    final db = await _databaseHelper.database;
    final whereClauses = <String>[
      'f.client_id = ?',
      'f.${DatabaseColumns.isDeleted} = 0',
    ];
    final args = <Object?>[clientId];
    final normalizedFilter = filter?.trim().toLowerCase();
    if (normalizedFilter == 'completed') {
      whereClauses.add("f.status = 'Completed'");
    } else if (normalizedFilter == 'missed') {
      whereClauses.add("f.status = 'Missed'");
    }

    final result = await db.rawQuery(
      _baseFollowUpQuery(whereClause: whereClauses.join(' AND ')),
      args,
    );
    return result.map(FollowUpModel.fromMap).toList();
  }

  Future<void> markPendingPastFollowUpsAsMissed() async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.followUps,
      {
        'status': 'Missed',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where:
          "status = ? AND follow_up_date_time < ? AND ${DatabaseColumns.isDeleted} = 0",
      whereArgs: ['Pending', DateTime.now().millisecondsSinceEpoch],
    );
  }

  bool isMissedFollowUp(FollowUpModel followUp, {DateTime? now}) {
    return FollowUpStatusHelper.isMissed(
      status: followUp.status,
      followUpDateTime: followUp.followUpDateTime,
      now: now ?? DateTime.now(),
    );
  }

  String _baseFollowUpQuery({required String whereClause}) {
    return '''
      SELECT f.*, c.name AS client_name, c.mobile AS client_mobile, p.policy_number
      FROM ${DatabaseTables.followUps} f
      LEFT JOIN ${DatabaseTables.clients} c ON c.id = f.client_id
      LEFT JOIN ${DatabaseTables.policies} p ON p.id = f.policy_id
      WHERE $whereClause
      ORDER BY f.follow_up_date_time ASC
    ''';
  }
}
