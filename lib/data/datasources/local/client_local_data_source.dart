import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/domain/entities/upcoming_client_event.dart';
import 'package:sqflite/sqflite.dart';

/// Encapsulates all SQLite access for client records.
///
/// Complex queries live here so repositories can focus on permissions,
/// orchestration, and sync behavior instead of SQL details.
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
    // Policy count is fetched with the client because most detail/list screens
    // need it immediately and it avoids a second query per record.
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

  Future<bool> hasDuplicateMobile({
    required String businessId,
    required String mobile,
    required bool isAdmin,
    required String userId,
    String? excludingClientId,
  }) async {
    final db = await _databaseHelper.database;
    final whereClauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      'mobile = ?',
      '${DatabaseColumns.isDeleted} = 0',
    ];
    final whereArgs = <Object?>[businessId, mobile];
    if (!isAdmin) {
      whereClauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)',
      );
      whereArgs.addAll([userId, userId, userId]);
    }
    if (excludingClientId != null && excludingClientId.isNotEmpty) {
      whereClauses.add('${DatabaseColumns.id} != ?');
      whereArgs.add(excludingClientId);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.clients} WHERE ${whereClauses.join(' AND ')}',
      whereArgs,
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<ClientModel?> findClientByMobile({
    required String businessId,
    required String mobile,
    required bool isAdmin,
    required String userId,
    String? excludingClientId,
  }) async {
    final db = await _databaseHelper.database;
    final whereClauses = <String>[
      '${DatabaseColumns.businessId} = ?',
      'mobile = ?',
      '${DatabaseColumns.isDeleted} = 0',
    ];
    final args = <Object?>[businessId, mobile];
    if (!isAdmin) {
      whereClauses.add(
        '(${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)',
      );
      args.addAll([userId, userId, userId]);
    }
    if (excludingClientId != null && excludingClientId.isNotEmpty) {
      whereClauses.add('${DatabaseColumns.id} != ?');
      args.add(excludingClientId);
    }

    final result = await db.rawQuery('''
      SELECT c.*,
        (
          SELECT COUNT(*)
          FROM ${DatabaseTables.policies} p
          WHERE p.client_id = c.id AND p.is_deleted = 0
        ) AS policy_count
      FROM ${DatabaseTables.clients} c
      WHERE ${whereClauses.join(' AND ')}
      LIMIT 1
      ''', args);

    if (result.isEmpty) {
      return null;
    }
    return ClientModel.fromMap(result.first);
  }

  Future<List<UpcomingClientEvent>> getUpcomingSpecialDates({
    required String businessId,
    required bool isAdmin,
    required String userId,
    int withinDays = 30,
  }) async {
    // Special dates are derived in Dart because the source values are stored as
    // full timestamps, but the recurrence rule is based only on month/day.
    final clients = isAdmin
        ? await getClientsForAdmin(
            businessId: businessId,
            limit: 500,
            offset: 0,
          )
        : await getClientsForAgent(
            businessId: businessId,
            userId: userId,
            limit: 500,
            offset: 0,
          );
    final now = DateTime.now();
    final events = <UpcomingClientEvent>[];

    for (final client in clients) {
      final birthday = _nextOccurrence(client.dateOfBirthMs, now);
      if (birthday != null && birthday.difference(now).inDays <= withinDays) {
        events.add(
          UpcomingClientEvent(
            clientId: client.id,
            clientName: client.name,
            mobile: client.mobile,
            eventType: 'birthday',
            label: 'Birthday',
            eventDateMs: birthday.millisecondsSinceEpoch,
            profileImagePath: client.profileImagePath,
          ),
        );
      }

      final specialDate = _nextOccurrence(client.specialDateMs, now);
      if (specialDate != null &&
          specialDate.difference(now).inDays <= withinDays) {
        events.add(
          UpcomingClientEvent(
            clientId: client.id,
            clientName: client.name,
            mobile: client.mobile,
            eventType: 'special_date',
            label: client.specialDateLabel ?? 'Special Date',
            eventDateMs: specialDate.millisecondsSinceEpoch,
            profileImagePath: client.profileImagePath,
          ),
        );
      }
    }

    events.sort((a, b) => a.eventDateMs.compareTo(b.eventDateMs));
    return events.take(10).toList();
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

  DateTime? _nextOccurrence(int? value, DateTime now) {
    if (value == null) {
      return null;
    }
    // Birthdays and anniversaries repeat yearly, so the stored source year is
    // ignored when calculating the next upcoming occurrence.
    final source = DateTime.fromMillisecondsSinceEpoch(value);
    var occurrence = DateTime(now.year, source.month, source.day);
    if (occurrence.isBefore(DateTime(now.year, now.month, now.day))) {
      occurrence = DateTime(now.year + 1, source.month, source.day);
    }
    return occurrence;
  }
}
