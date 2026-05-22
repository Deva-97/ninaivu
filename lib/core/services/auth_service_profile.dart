part of 'auth_service.dart';

extension _AuthServiceProfile on AuthService {
  Future<void> _completeProfile({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  }) async {
    final firebaseUser = firebaseAuth?.currentUser;
    if (firebaseUser == null) {
      throw Exception(
        'Profile setup requires an authenticated online session. '
        'Please sign in again when connectivity is available.',
      );
    }

    final role = _getRoleFromInviteCode(inviteCode);
    final now = DateTime.now().millisecondsSinceEpoch;
    // The first completed profile is written locally and queued like any other
    // business record so onboarding still works with flaky connectivity.
    final user = AppUserModel(
      id: firebaseUser.uid,
      businessId: UserRemoteDataSource.defaultBusinessId,
      name: name,
      mobile: mobile,
      email: email,
      role: role,
      status: 'active',
      profileCompleted: true,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      syncStatus: 'pending_create',
      createdBy: firebaseUser.uid,
      agentId: role == 'agent' ? firebaseUser.uid : null,
    );

    await userLocalDataSource.insertOrUpdateUser(user);
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: user.businessId,
        tableName: DatabaseTables.users,
        recordId: user.id,
        operation: 'create',
        payload: user.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending_create',
      ),
    );
    await _syncService.syncPendingDataBestEffort();

    final preferences = await AppPreferences.getInstance();
    await preferences.saveSession(
      userId: user.id,
      role: user.role,
      businessId: user.businessId,
    );
    await BackgroundSyncService.instance.ensureRegistered();

    _navigateByRole(role);
  }

  String _getRoleFromInviteCode(String inviteCode) {
    final code = inviteCode.trim().toUpperCase();
    if (code == 'NINAIVU_ADMIN') {
      return 'admin';
    }
    if (code == 'NINAIVU_AGENT') {
      return 'agent';
    }
    throw Exception('Invalid invite code');
  }
}
