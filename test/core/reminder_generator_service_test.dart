import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/services/reminder_generator_service.dart';
import 'package:ninaivu/data/models/policy_model.dart';

void main() {
  group('ReminderGeneratorService', () {
    test('generates the expected reminder schedule', () {
      final service = ReminderGeneratorService();
      final endDate = DateTime(2026, 12, 31).millisecondsSinceEpoch;
      final policy = PolicyModel(
        id: 'policy-1',
        businessId: 'biz-1',
        clientId: 'client-1',
        insuranceType: 'Car',
        policyNumber: 'POL-001',
        companyName: 'Ninaivu Insurance',
        startDate: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        endDate: endDate,
        premiumAmount: 1000,
        status: 'Active',
        createdBy: 'agent-1',
        createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        isDeleted: false,
        syncStatus: 'pending_create',
      );

      final reminders = service.generateForPolicy(policy);

      expect(reminders.length, 5);
      expect(reminders.map((r) => r.reminderType).toList(), [
        '30 Days Before',
        '15 Days Before',
        '7 Days Before',
        '1 Days Before',
        'On Expiry',
      ]);
      expect(
        reminders.last.reminderDateTime,
        DateTime(2026, 12, 31, 9).millisecondsSinceEpoch,
      );
    });
  });
}
