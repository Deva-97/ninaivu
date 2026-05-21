import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/data/models/policy_model.dart';

/// Combined search payload returned to the global search screen.
class GlobalSearchResult {
  const GlobalSearchResult({
    required this.clients,
    required this.policies,
    required this.agents,
  });

  final List<ClientModel> clients;
  final List<PolicyModel> policies;
  final List<AppUserModel> agents;
}

/// Runs a cross-feature local search over clients, policies, and agents.
///
/// Search is done against SQLite so results stay fast and available even when
/// the device is offline.
class GlobalSearchService {
  GlobalSearchService({
    DatabaseHelper? databaseHelper,
    UserLocalDataSource? userLocalDataSource,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource();

  final DatabaseHelper _databaseHelper;
  final UserLocalDataSource _userLocalDataSource;

  Future<GlobalSearchResult> search(String query) async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }

    final db = await _databaseHelper.database;
    final role = currentUser.role.toAppRole();
    final isAdmin = PermissionHelper.canManageAllClients(role);
    final pattern = '%${query.trim()}%';

    // Each query applies the same role-based visibility rules used elsewhere so
    // search never reveals records that the user could not open directly.
    final clients = await db.rawQuery(
      '''
      SELECT c.*,
        (
          SELECT COUNT(*)
          FROM ${DatabaseTables.policies} p
          WHERE p.client_id = c.id AND p.is_deleted = 0
        ) AS policy_count
      FROM ${DatabaseTables.clients} c
      WHERE c.${DatabaseColumns.businessId} = ?
        AND c.${DatabaseColumns.isDeleted} = 0
        AND (c.name LIKE ? OR c.mobile LIKE ?)
        ${isAdmin ? '' : 'AND (c.${DatabaseColumns.createdBy} = ? OR c.${DatabaseColumns.agentId} = ? OR c.${DatabaseColumns.assignedTo} = ?)'}
      ORDER BY c.updated_at DESC
      LIMIT 20
      ''',
      [
        currentUser.businessId,
        pattern,
        pattern,
        if (!isAdmin) ...[currentUser.id, currentUser.id, currentUser.id],
      ],
    );

    final policies = await db.rawQuery(
      '''
      SELECT *
      FROM ${DatabaseTables.policies}
      WHERE ${DatabaseColumns.businessId} = ?
        AND ${DatabaseColumns.isDeleted} = 0
        AND (
          policy_number LIKE ?
          OR vehicle_number LIKE ?
          OR insurance_type LIKE ?
          OR company_name LIKE ?
        )
        ${isAdmin ? '' : 'AND (${DatabaseColumns.createdBy} = ? OR ${DatabaseColumns.agentId} = ? OR ${DatabaseColumns.assignedTo} = ?)'}
      ORDER BY updated_at DESC
      LIMIT 20
      ''',
      [
        currentUser.businessId,
        pattern,
        pattern,
        pattern,
        pattern,
        if (!isAdmin) ...[currentUser.id, currentUser.id, currentUser.id],
      ],
    );

    final agents = isAdmin
        ? await db.query(
            DatabaseTables.users,
            where:
                '${DatabaseColumns.businessId} = ? AND ${DatabaseColumns.isDeleted} = 0 '
                'AND role = ? AND (name LIKE ? OR mobile LIKE ?)',
            whereArgs: [currentUser.businessId, 'agent', pattern, pattern],
            orderBy: 'name COLLATE NOCASE ASC',
            limit: 20,
          )
        : <Map<String, Object?>>[];

    return GlobalSearchResult(
      clients: clients.map(ClientModel.fromMap).toList(),
      policies: policies.map(PolicyModel.fromMap).toList(),
      agents: agents.map(AppUserModel.fromMap).toList(),
    );
  }
}
