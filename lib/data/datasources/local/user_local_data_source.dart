import 'package:insurance_reminders/core/database/database_helper.dart';
import 'package:insurance_reminders/core/database/database_tables.dart';
import 'package:insurance_reminders/core/services/app_preferences.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalDataSource {
  UserLocalDataSource({DatabaseHelper? databaseHelper})
    : databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper databaseHelper;

  Future<AppUserModel?> getCurrentUser() async {
    final preferences = await AppPreferences.getInstance();
    final userId = preferences.userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    return getUserById(userId);
  }

  Future<AppUserModel?> getUserById(String id) async {
    return _getUserById(id, includeDeleted: false);
  }

  Future<AppUserModel?> getUserByIdIncludingDeleted(String id) async {
    return _getUserById(id, includeDeleted: true);
  }

  Future<AppUserModel?> _getUserById(String id, {required bool includeDeleted}) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      DatabaseTables.users,
      where: includeDeleted
          ? '${DatabaseColumns.id} = ?'
          : '${DatabaseColumns.id} = ? AND ${DatabaseColumns.isDeleted} = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return AppUserModel.fromMap(result.first);
  }

  Future<List<AppUserModel>> getUsersByRole(String role, {String? query}) async {
    final db = await databaseHelper.database;
    final whereClauses = <String>[
      'role = ?',
      '${DatabaseColumns.isDeleted} = 0',
    ];
    final whereArgs = <Object?>[role];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(name LIKE ? OR mobile LIKE ? OR email LIKE ?)');
      final pattern = '%${query.trim()}%';
      whereArgs.addAll([pattern, pattern, pattern]);
    }

    final result = await db.query(
      DatabaseTables.users,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return result.map(AppUserModel.fromMap).toList();
  }

  Future<List<AppUserModel>> getAgents({String? query}) =>
      getUsersByRole('agent', query: query);

  Future<List<AppUserModel>> getCustomers({String? query}) =>
      getUsersByRole('customer', query: query);

  Future<void> insertOrUpdateUser(AppUserModel user) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseTables.users,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserStatus({
    required String userId,
    required String status,
    required String syncStatus,
  }) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseTables.users,
      {
        'status': status,
        DatabaseColumns.syncStatus: syncStatus,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> softDeleteUser(String userId) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseTables.users,
      {
        DatabaseColumns.isDeleted: 1,
        DatabaseColumns.syncStatus: 'pending_delete',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [userId],
    );
  }

  Future<List<AppUserModel>> searchUsers(String query) async {
    final db = await databaseHelper.database;
    final pattern = '%${query.trim()}%';
    final result = await db.query(
      DatabaseTables.users,
      where:
          '${DatabaseColumns.isDeleted} = 0 AND '
          '(name LIKE ? OR mobile LIKE ? OR email LIKE ?)',
      whereArgs: [pattern, pattern, pattern],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return result.map(AppUserModel.fromMap).toList();
  }

  Future<int> countAgents() async => _countUsersByRole('agent');

  Future<int> countCustomers() async => _countUsersByRole('customer');

  Future<void> markUserSynced(String id) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseTables.users,
      {
        DatabaseColumns.syncStatus: 'synced',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markUserSyncStatus({
    required String id,
    required String syncStatus,
  }) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseTables.users,
      {
        DatabaseColumns.syncStatus: syncStatus,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> _countUsersByRole(String role) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.users} '
      'WHERE role = ? AND ${DatabaseColumns.isDeleted} = 0',
      [role],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
