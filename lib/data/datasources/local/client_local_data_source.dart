import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:sqflite/sqflite.dart';

class ClientLocalDataSource {
  ClientLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> insertClient(ClientModel client) async {
    final db = await _databaseHelper.database;
    await db.insert(
      DatabaseTables.clients,
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateClient(ClientModel client) => insertClient(client);

  Future<void> softDeleteClient(String clientId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.clients,
      {
        DatabaseColumns.isDeleted: 1,
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
        DatabaseColumns.syncStatus: 'pending_delete',
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [clientId],
    );
  }

  Future<ClientModel?> getClientById(String clientId) async {
    return _getClientById(clientId, includeDeleted: false);
  }

  Future<ClientModel?> getClientByIdIncludingDeleted(String clientId) async {
    return _getClientById(clientId, includeDeleted: true);
  }

  Future<ClientModel?> _getClientById(
    String clientId, {
    required bool includeDeleted,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT c.*,
        (
          SELECT COUNT(*)
          FROM ${DatabaseTables.policies} p
          WHERE p.client_id = c.id AND p.is_deleted = 0
        ) AS policy_count
      FROM ${DatabaseTables.clients} c
      WHERE c.${DatabaseColumns.id} = ?
      ${includeDeleted ? '' : 'AND c.${DatabaseColumns.isDeleted} = 0'}
      LIMIT 1
      ''',
      [clientId],
    );

    if (result.isEmpty) {
      return null;
    }

    return ClientModel.fromMap(result.first);
  }

  Future<void> markClientSynced(String clientId) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseTables.clients,
      {
        DatabaseColumns.syncStatus: 'synced',
        DatabaseColumns.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DatabaseColumns.id} = ?',
      whereArgs: [clientId],
    );
  }

  Future<List<ClientModel>> getClientsForAdmin({
    required String businessId,
    String? query,
    int limit = 50,
    int offset = 0,
  }) {
    return _getClients(
      whereClauses: [
        'c.${DatabaseColumns.businessId} = ?',
        'c.${DatabaseColumns.isDeleted} = 0',
      ],
      whereArgs: [businessId],
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<ClientModel>> getClientsForAgent({
    required String businessId,
    required String userId,
    String? query,
    int limit = 50,
    int offset = 0,
  }) {
    return _getClients(
      whereClauses: [
        'c.${DatabaseColumns.businessId} = ?',
        'c.${DatabaseColumns.isDeleted} = 0',
        '(c.${DatabaseColumns.createdBy} = ? OR c.${DatabaseColumns.agentId} = ?)',
      ],
      whereArgs: [businessId, userId, userId],
      query: query,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<ClientModel>> searchClientsByNameOrMobile({
    required String businessId,
    required bool isAdmin,
    required String userId,
    required String query,
  }) {
    return isAdmin
        ? getClientsForAdmin(businessId: businessId, query: query)
        : getClientsForAgent(
            businessId: businessId,
            userId: userId,
            query: query,
          );
  }

  Future<int> countClientsForAdmin(String businessId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.clients} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0',
      [businessId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countClientsForAgent({
    required String businessId,
    required String userId,
  }) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.clients} '
      'WHERE ${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
      'AND (${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ?)',
      [businessId, userId, userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ClientModel>> getClientsPaginated({
    required String businessId,
    required bool isAdmin,
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return isAdmin
        ? getClientsForAdmin(
            businessId: businessId,
            limit: limit,
            offset: offset,
          )
        : getClientsForAgent(
            businessId: businessId,
            userId: userId,
            limit: limit,
            offset: offset,
          );
  }

  Future<List<ClientModel>> _getClients({
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
      clauses.add('(c.name LIKE ? OR c.mobile LIKE ?)');
      final pattern = '%${query.trim()}%';
      args.addAll([pattern, pattern]);
    }

    final result = await db.rawQuery(
      '''
      SELECT c.*,
        (
          SELECT COUNT(*)
          FROM ${DatabaseTables.policies} p
          WHERE p.client_id = c.id AND p.is_deleted = 0
        ) AS policy_count
      FROM ${DatabaseTables.clients} c
      WHERE ${clauses.join(' AND ')}
      ORDER BY c.updated_at DESC
      LIMIT ? OFFSET ?
      ''',
      [...args, limit, offset],
    );

    return result.map(ClientModel.fromMap).toList();
  }
}
