import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/domain/entities/dashboard_stats.dart';
import 'package:sqflite/sqflite.dart';

class DashboardLocalDataSource {
  DashboardLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<AdminDashboardStats> getAdminStats(String businessId) async {
    final db = await _databaseHelper.database;
    final range = _dateRange();

    final agents = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.users} '
      'WHERE role = ? AND ${DatabaseColumns.isDeleted} = 0 AND ${DatabaseColumns.businessId} = ?',
      ['agent', businessId],
    );
    final customers = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.users} '
      'WHERE role = ? AND ${DatabaseColumns.isDeleted} = 0 AND ${DatabaseColumns.businessId} = ?',
      ['customer', businessId],
    );
    final clients = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.clients} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0',
      [businessId],
    );
    final policies = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0',
      [businessId],
    );
    final renewalsToday = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date >= ? AND end_date < ?',
      [businessId, range.startOfToday, range.endOfToday],
    );
    final upcoming7Days = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date >= ? AND end_date < ?',
      [businessId, range.startOfToday, range.upcoming7Days],
    );
    final expiredPolicies = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date < ?',
      [businessId, range.startOfToday],
    );
    final pendingFollowUps = await _count(
      db,
      "SELECT COUNT(*) FROM ${DatabaseTables.followUps} "
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      "AND status = 'Pending' AND follow_up_date_time >= ?",
      [businessId, DateTime.now().millisecondsSinceEpoch],
    );
    final missedFollowUps = await _count(
      db,
      "SELECT COUNT(*) FROM ${DatabaseTables.followUps} "
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      "AND (status = 'Missed' OR (status = 'Pending' AND follow_up_date_time < ?))",
      [businessId, DateTime.now().millisecondsSinceEpoch],
    );

    return AdminDashboardStats(
      totalAgents: agents,
      totalCustomers: customers,
      totalClients: clients,
      totalPolicies: policies,
      renewalsToday: renewalsToday,
      upcoming7Days: upcoming7Days,
      expiredPolicies: expiredPolicies,
      pendingFollowUps: pendingFollowUps,
      missedFollowUps: missedFollowUps,
    );
  }

  Future<AgentDashboardStats> getAgentStats({
    required String businessId,
    required String userId,
  }) async {
    final db = await _databaseHelper.database;
    final range = _dateRange();
    const ownClientFilter =
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)';
    const ownPolicyFilter =
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)';
    const ownFollowUpFilter =
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)';

    final myClients = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.clients} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND $ownClientFilter',
      [businessId, userId, userId],
    );
    final myPolicies = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND $ownPolicyFilter',
      [businessId, userId, userId],
    );
    final renewalsToday = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date >= ? AND end_date < ? '
      'AND $ownPolicyFilter',
      [businessId, range.startOfToday, range.endOfToday, userId, userId],
    );
    final upcoming7Days = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date >= ? AND end_date < ? '
      'AND $ownPolicyFilter',
      [businessId, range.startOfToday, range.upcoming7Days, userId, userId],
    );
    final upcoming30Days = await _count(
      db,
      'SELECT COUNT(*) FROM ${DatabaseTables.policies} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND end_date >= ? AND end_date < ? '
      'AND $ownPolicyFilter',
      [businessId, range.startOfToday, range.upcoming30Days, userId, userId],
    );
    final followUpsToday = await _count(
      db,
      "SELECT COUNT(*) FROM ${DatabaseTables.followUps} "
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND follow_up_date_time >= ? AND follow_up_date_time < ? '
      'AND $ownFollowUpFilter',
      [
        businessId,
        range.startOfToday,
        range.endOfToday,
        userId,
        userId,
        userId,
      ],
    );
    final missedFollowUps = await _count(
      db,
      "SELECT COUNT(*) FROM ${DatabaseTables.followUps} "
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      "AND (status = 'Missed' OR (status = 'Pending' AND follow_up_date_time < ?)) "
      'AND $ownFollowUpFilter',
      [
        businessId,
        DateTime.now().millisecondsSinceEpoch,
        userId,
        userId,
        userId,
      ],
    );

    return AgentDashboardStats(
      myClients: myClients,
      myPolicies: myPolicies,
      renewalsToday: renewalsToday,
      upcoming7Days: upcoming7Days,
      upcoming30Days: upcoming30Days,
      followUpsToday: followUpsToday,
      missedFollowUps: missedFollowUps,
    );
  }

  Future<int> _count(Database db, String query, List<Object?> args) async {
    final result = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  _DateRange _dateRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _DateRange(
      startOfToday: start.millisecondsSinceEpoch,
      endOfToday: start.add(const Duration(days: 1)).millisecondsSinceEpoch,
      upcoming7Days: start.add(const Duration(days: 8)).millisecondsSinceEpoch,
      upcoming30Days: start
          .add(const Duration(days: 31))
          .millisecondsSinceEpoch,
    );
  }
}

class _DateRange {
  const _DateRange({
    required this.startOfToday,
    required this.endOfToday,
    required this.upcoming7Days,
    required this.upcoming30Days,
  });

  final int startOfToday;
  final int endOfToday;
  final int upcoming7Days;
  final int upcoming30Days;
}
