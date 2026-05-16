import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';
import 'package:insurance_reminders/data/datasources/local/follow_up_local_data_source.dart';
import 'package:insurance_reminders/data/datasources/local/user_local_data_source.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';
import 'package:insurance_reminders/data/models/follow_up_model.dart';
import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/repositories/follow_up_repository.dart';
import 'package:uuid/uuid.dart';

class FollowUpRepositoryImpl implements FollowUpRepository {
  FollowUpRepositoryImpl({
    FollowUpLocalDataSource? localDataSource,
    UserLocalDataSource? userLocalDataSource,
    Uuid? uuid,
  }) : _localDataSource = localDataSource ?? FollowUpLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _uuid = uuid ?? const Uuid();

  final FollowUpLocalDataSource _localDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final Uuid _uuid;

  @override
  Future<FollowUp> addFollowUp(FollowUp followUp) async {
    final currentUser = await _requireCurrentUser();
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = FollowUpModel.fromEntity(followUp).copyWith(
      id: followUp.id.isEmpty ? _uuid.v4() : followUp.id,
      businessId: currentUser.businessId,
      createdBy: followUp.createdBy.isEmpty ? currentUser.id : followUp.createdBy,
      agentId:
          followUp.agentId ??
          (currentUser.role == AppRole.agent.value ? currentUser.id : null),
      assignedTo:
          followUp.assignedTo ??
          followUp.agentId ??
          (currentUser.role == AppRole.agent.value ? currentUser.id : currentUser.id),
      createdAt: followUp.createdAt == 0 ? now : followUp.createdAt,
      updatedAt: now,
      syncStatus: 'pending_create',
    );
    await _localDataSource.insertFollowUp(model);
    return model;
  }

  @override
  Future<FollowUp> updateFollowUp(FollowUp followUp) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUp.id);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);

    final model = FollowUpModel.fromEntity(followUp).copyWith(
      businessId: existing.businessId,
      createdBy: existing.createdBy,
      createdAt: existing.createdAt,
      agentId: followUp.agentId ?? existing.agentId,
      assignedTo: followUp.assignedTo ?? existing.assignedTo ?? existing.agentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'pending_update',
    );
    await _localDataSource.updateFollowUp(model);
    return model;
  }

  @override
  Future<void> deleteFollowUp(String followUpId) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUpId);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);
    await _localDataSource.softDeleteFollowUp(followUpId);
  }

  @override
  Future<void> markFollowUpCompleted(String followUpId) async {
    final currentUser = await _requireCurrentUser();
    final existing = await _localDataSource.getFollowUpById(followUpId);
    if (existing == null) {
      throw Exception('Follow-up not found');
    }
    _ensureFollowUpAccess(currentUser, existing);
    await _localDataSource.markFollowUpCompleted(followUpId);
  }

  @override
  Future<List<FollowUp>> getTodayFollowUps() => getFollowUps(filter: 'today');

  @override
  Future<List<FollowUp>> getMissedFollowUps() => getFollowUps(filter: 'missed');

  @override
  Future<List<FollowUp>> getUpcomingFollowUps({int withinDays = 30}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getFollowUps(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      filter: 'upcoming',
      withinDays: withinDays,
    );
  }

  @override
  Future<List<FollowUp>> getFollowUps({String filter = 'today'}) async {
    final currentUser = await _requireCurrentUser();
    final role = currentUser.role.toAppRole();
    return _localDataSource.getFollowUps(
      businessId: currentUser.businessId,
      isAdmin: PermissionHelper.canManageAllClients(role),
      userId: currentUser.id,
      filter: filter,
    );
  }

  @override
  Future<FollowUp?> getFollowUpById(String followUpId) =>
      _localDataSource.getFollowUpById(followUpId);

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }

  void _ensureFollowUpAccess(AppUserModel currentUser, FollowUpModel followUp) {
    final role = currentUser.role.toAppRole();
    if (PermissionHelper.canManageAllClients(role)) {
      return;
    }

    final canAccess =
        followUp.createdBy == currentUser.id ||
        followUp.agentId == currentUser.id ||
        followUp.assignedTo == currentUser.id;
    if (!canAccess) {
      throw Exception('You can only manage your own follow-ups.');
    }
  }
}
