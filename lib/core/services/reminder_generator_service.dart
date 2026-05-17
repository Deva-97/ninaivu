import 'package:ninaivu/data/models/policy_model.dart';
import 'package:ninaivu/data/models/reminder_model.dart';
import 'package:uuid/uuid.dart';

class ReminderGeneratorService {
  ReminderGeneratorService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  static const reminderOffsets = <int>[30, 15, 7, 1, 0];

  List<ReminderModel> generateForPolicy(PolicyModel policy) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(policy.endDate);
    final baseExpiry = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );

    return reminderOffsets.map((daysBefore) {
      final scheduledDate = DateTime(
        baseExpiry.year,
        baseExpiry.month,
        baseExpiry.day - daysBefore,
        9,
      );
      final reminderId = _uuid.v4();
      return ReminderModel(
        id: reminderId,
        businessId: policy.businessId,
        clientId: policy.clientId,
        policyId: policy.id,
        reminderDateTime: scheduledDate.millisecondsSinceEpoch,
        reminderType: daysBefore == 0 ? 'On Expiry' : '$daysBefore Days Before',
        status: scheduledDate.millisecondsSinceEpoch < now
            ? 'missed'
            : 'pending',
        notificationId: _notificationIdFor(reminderId),
        createdBy: policy.createdBy,
        agentId: policy.agentId,
        subAgentId: policy.subAgentId,
        customerUserId: policy.customerUserId,
        assignedTo: policy.assignedTo ?? policy.agentId ?? policy.createdBy,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        syncStatus: 'pending_create',
      );
    }).toList();
  }

  int _notificationIdFor(String value) {
    var hash = 5381;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
    }
    return hash & 0x7fffffff;
  }
}
