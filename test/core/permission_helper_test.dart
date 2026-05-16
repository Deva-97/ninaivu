import 'package:flutter_test/flutter_test.dart';
import 'package:insurance_reminders/core/permissions/permission_helper.dart';
import 'package:insurance_reminders/core/permissions/user_role.dart';

void main() {
  group('PermissionHelper', () {
    test('admin can access admin and agent features', () {
      expect(PermissionHelper.canManageUsers(AppRole.admin), isTrue);
      expect(PermissionHelper.canViewGlobalDashboard(AppRole.admin), isTrue);
      expect(
        PermissionHelper.canAccessOwnRecord(
          role: AppRole.admin,
          currentUserId: 'admin-1',
          createdBy: 'other',
        ),
        isTrue,
      );
    });

    test('agent cannot access admin-only features', () {
      expect(PermissionHelper.canManageUsers(AppRole.agent), isFalse);
      expect(PermissionHelper.canViewGlobalDashboard(AppRole.agent), isFalse);
      expect(
        PermissionHelper.canAccessOwnRecord(
          role: AppRole.agent,
          currentUserId: 'agent-1',
          createdBy: 'owner',
          agentId: 'agent-2',
          assignedTo: 'agent-3',
        ),
        isFalse,
      );
      expect(
        PermissionHelper.canAccessOwnRecord(
          role: AppRole.agent,
          currentUserId: 'agent-1',
          createdBy: 'owner',
          agentId: 'agent-1',
        ),
        isTrue,
      );
    });
  });
}
