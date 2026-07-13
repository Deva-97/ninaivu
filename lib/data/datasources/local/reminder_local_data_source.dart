import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/models/reminder_model.dart';
import 'package:sqflite/sqflite.dart';

class ReminderLocalDataSource {
  ReminderLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> insertReminder(ReminderModel reminder) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.reminders,
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertReminders(List<ReminderModel> reminders) async {
    if (reminders.isEmpty) {
      return;
    }

    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final reminder in reminders) {
        batch.insert(
          DatabaseTables.reminders,
          reminder.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> updateReminder(ReminderModel reminder) =>
      insertReminder(reminder);

  Future<ReminderModel?> getReminderById(String reminderId) async {
    await markDueRemindersAsMissed();
    return _getReminderById(reminderId, includeDeleted: false);
  }

  Future<ReminderModel?> getReminderByIdIncludingDeleted(
    String reminderId,
  ) async {
    return _getReminderById(reminderId, includeDeleted: true);
  }

  Future<ReminderModel?> _getReminderById(
    String reminderId, {
    required bool includeDeleted,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      _baseReminderQuery(
        whereClause: includeDeleted
            ? 'r.${DatabaseColumns.id} = ?'
            : 'r.${DatabaseColumns.id} = ? AND r.${DatabaseColumns.isDeleted} = 0',
      ),
      [reminderId],
    );

    if (result.isEmpty) {
      return null;
    }

    return ReminderModel.fromMap(result.first);
  }

  Future<void> markReminderSynced(String reminderId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.reminders,
      {
        DatabaseColumns.syncStatus: 'synced',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [reminderId],
    );
  }

  Future<List<ReminderModel>> getReminders({
    required String businessId,
    required bool isAdmin,
    required String userId,
    String filter = 'pending',
  }) async {
    await markDueRemindersAsMissed();
    final db = await _databaseHelper.database;
    final normalizedFilter = filter.trim().toLowerCase();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    final startMs = startOfToday.millisecondsSinceEpoch;
    final next7 = startOfToday
        .add(const Duration(days: 8))
        .millisecondsSinceEpoch;
    final next30 = startOfToday
        .add(const Duration(days: 31))
        .millisecondsSinceEpoch;

    final whereClauses = <String>[
      'r.${DatabaseColumns.businessId} = ?',
      'r.${DatabaseColumns.isDeleted} = 0',
    ];
    final args = <Object?>[businessId];

    if (!isAdmin) {
      whereClauses.add(
        '(r.${DatabaseColumns.createdBy} = ? OR r.${DatabaseColumns.agentId} = ? OR r.${DatabaseColumns.assignedTo} = ?)',
      );
      args.addAll([userId, userId, userId]);
    }

    switch (normalizedFilter) {
      case 'pending':
      case 'all_upcoming':
      case 'allupcoming':
        whereClauses.add(
          "r.status IN ('pending', 'notified') AND r.reminder_date_time >= ?",
        );
        args.add(startMs);
        break;
      case 'today':
        whereClauses.add(
          'r.reminder_date_time >= ? AND r.reminder_date_time < ?',
        );
        args.addAll([startMs, endOfToday]);
        break;
      case 'upcoming7days':
      case 'upcoming_7_days':
      case 'upcoming7':
        whereClauses.add(
          "r.status IN ('pending', 'notified') AND r.reminder_date_time >= ? AND r.reminder_date_time < ?",
        );
        args.addAll([startMs, next7]);
        break;
      case 'upcoming30days':
      case 'upcoming_30_days':
      case 'upcoming30':
        whereClauses.add(
          "r.status IN ('pending', 'notified') AND r.reminder_date_time >= ? AND r.reminder_date_time < ?",
        );
        args.addAll([startMs, next30]);
        break;
      case 'missed':
        whereClauses.add("r.status = 'missed'");
        break;
      case 'completed':
        whereClauses.add("r.status = 'completed'");
        break;
      default:
        break;
    }

    final result = await db.rawQuery(
      _baseReminderQuery(whereClause: whereClauses.join(' AND ')),
      args,
    );
    return result.map(ReminderModel.fromMap).toList();
  }

  Future<List<ReminderModel>> getRemindersByPolicy(String policyId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseTables.reminders,
      where: 'policy_id = ? AND ${DatabaseColumns.isDeleted} = 0',
      whereArgs: [policyId],
    );
    return result.map(ReminderModel.fromMap).toList();
  }

  Future<List<ReminderModel>> getRemindersByClient(String clientId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      _baseReminderQuery(
        whereClause: 'r.client_id = ? AND r.${DatabaseColumns.isDeleted} = 0',
      ),
      [clientId],
    );
    return result.map(ReminderModel.fromMap).toList();
  }

  Future<void> markReminderCompleted(String reminderId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.reminders,
      {
        'status': 'completed',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [reminderId],
    );
  }

  Future<void> markReminderRenewed(String reminderId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.reminders,
      {
        'status': 'renewed',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [reminderId],
    );
  }

  Future<void> markDueRemindersAsMissed() async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.reminders,
      {
        'status': 'missed',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_update',
      },
      where:
          "status = ? AND reminder_date_time < ? AND ${DatabaseColumns.isDeleted} = 0",
      whereArgs: ['pending', DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<void> softDeleteByPolicy(String policyId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.reminders,
      {
        DatabaseColumns.isDeleted: 1,
        'status': 'cancelled',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_delete',
      },
      where: 'policy_id = ? AND ${DatabaseColumns.isDeleted} = 0',
      whereArgs: [policyId],
    );
  }

  String _baseReminderQuery({required String whereClause}) {
    return '''
      SELECT r.*, c.name AS client_name, c.mobile AS client_mobile, p.policy_number, p.company_name
      FROM ${DatabaseTables.reminders} r
      LEFT JOIN ${DatabaseTables.clients} c ON c.id = r.client_id
      LEFT JOIN ${DatabaseTables.policies} p ON p.id = r.policy_id
      WHERE $whereClause
      ORDER BY r.reminder_date_time ASC
    ''';
  }
}
