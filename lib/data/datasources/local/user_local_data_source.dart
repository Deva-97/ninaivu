import 'package:insurance_reminders/core/database/database_helper.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalDataSource {
  final DatabaseHelper databaseHelper;

  UserLocalDataSource({DatabaseHelper? databaseHelper})
    : databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<AppUserModel?> getUserById(String id) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return AppUserModel.fromMap(result.first);
  }

  Future<void> insertOrUpdateUser(AppUserModel user) async {
    final db = await databaseHelper.database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markUserSynced(String id) async {
    final db = await databaseHelper.database;

    await db.update(
      'users',
      {
        'sync_status': 'synced',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
