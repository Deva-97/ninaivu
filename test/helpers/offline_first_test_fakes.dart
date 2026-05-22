import 'package:ninaivu/core/services/reminder_generator_service.dart';
import 'package:ninaivu/core/services/reminder_scheduler_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/client_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/follow_up_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/policy_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/reminder_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/data/models/follow_up_model.dart';
import 'package:ninaivu/data/models/policy_model.dart';
import 'package:ninaivu/data/models/reminder_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';

const int testNowMs = 1704067200000;

AppUserModel testUser({
  String id = 'admin-1',
  String businessId = 'business-1',
  String role = 'admin',
}) {
  return AppUserModel(
    id: id,
    businessId: businessId,
    name: 'Test User',
    mobile: '9876543210',
    role: role,
    status: 'active',
    profileCompleted: true,
    createdAt: testNowMs,
    updatedAt: testNowMs,
    isDeleted: false,
    syncStatus: 'synced',
  );
}

ClientModel testClient({
  String id = 'client-1',
  String businessId = 'business-1',
  String createdBy = 'admin-1',
  String? agentId,
  String? assignedTo,
}) {
  return ClientModel(
    id: id,
    businessId: businessId,
    name: 'Client One',
    mobile: '9000000000',
    createdBy: createdBy,
    agentId: agentId,
    assignedTo: assignedTo,
    createdAt: testNowMs,
    updatedAt: testNowMs,
    isDeleted: false,
    syncStatus: 'synced',
  );
}

PolicyModel testPolicy({
  String id = 'policy-1',
  String businessId = 'business-1',
  String clientId = 'client-1',
  String createdBy = 'admin-1',
  String? agentId,
  String? assignedTo,
  int? endDate,
}) {
  return PolicyModel(
    id: id,
    businessId: businessId,
    clientId: clientId,
    insuranceType: 'Motor',
    policyNumber: 'POL123',
    companyName: 'ABC Insurance',
    startDate: testNowMs,
    endDate: endDate ?? testNowMs + const Duration(days: 30).inMilliseconds,
    premiumAmount: 12000,
    status: 'Active',
    renewalStatus: 'Not Contacted',
    createdBy: createdBy,
    agentId: agentId,
    assignedTo: assignedTo,
    createdAt: testNowMs,
    updatedAt: testNowMs,
    isDeleted: false,
    syncStatus: 'synced',
  );
}

ReminderModel testReminder({
  String id = 'reminder-1',
  String businessId = 'business-1',
  String clientId = 'client-1',
  String policyId = 'policy-1',
  String createdBy = 'admin-1',
  String? agentId,
  String? assignedTo,
  String status = 'pending',
  int? notificationId = 1001,
}) {
  return ReminderModel(
    id: id,
    businessId: businessId,
    clientId: clientId,
    policyId: policyId,
    reminderDateTime: testNowMs + const Duration(days: 10).inMilliseconds,
    reminderType: '7 Days Before',
    status: status,
    notificationId: notificationId,
    createdBy: createdBy,
    agentId: agentId,
    assignedTo: assignedTo,
    createdAt: testNowMs,
    updatedAt: testNowMs,
    isDeleted: false,
    syncStatus: 'synced',
  );
}

FollowUpModel testFollowUp({
  String id = 'follow-up-1',
  String businessId = 'business-1',
  String clientId = 'client-1',
  String createdBy = 'admin-1',
  String? agentId,
  String? assignedTo,
}) {
  return FollowUpModel(
    id: id,
    businessId: businessId,
    clientId: clientId,
    policyId: 'policy-1',
    followUpDateTime: testNowMs + const Duration(days: 1).inMilliseconds,
    type: 'Call',
    status: 'Pending',
    createdBy: createdBy,
    agentId: agentId,
    assignedTo: assignedTo,
    createdAt: testNowMs,
    updatedAt: testNowMs,
    isDeleted: false,
    syncStatus: 'synced',
  );
}

class FakeSyncService extends SyncService {
  FakeSyncService({this.result = 0});

  final int result;
  int syncPendingDataBestEffortCallCount = 0;

  @override
  Future<int> syncPendingDataBestEffort({
    bool removeSyncedQueueItems = true,
  }) async {
    syncPendingDataBestEffortCallCount++;
    return result;
  }
}

class FakeSyncQueueLocalDataSource extends SyncQueueLocalDataSource {
  final List<SyncQueueModel> enqueuedItems = <SyncQueueModel>[];

  @override
  Future<void> enqueue(SyncQueueModel item) async {
    enqueuedItems.add(item);
  }
}

class FakeUserLocalDataSource extends UserLocalDataSource {
  FakeUserLocalDataSource({
    this.currentUser,
    Map<String, AppUserModel>? usersById,
  }) : usersById = usersById ?? <String, AppUserModel>{};

  AppUserModel? currentUser;
  final Map<String, AppUserModel> usersById;
  final List<AppUserModel> savedUsers = <AppUserModel>[];

  @override
  Future<AppUserModel?> getCurrentUser() async => currentUser;

  @override
  Future<AppUserModel?> getUserById(String id) async => usersById[id];

  @override
  Future<void> insertOrUpdateUser(AppUserModel user) async {
    usersById[user.id] = user;
    savedUsers.add(user);
  }
}

class FakeClientLocalDataSource extends ClientLocalDataSource {
  Map<String, ClientModel> clientsById;

  FakeClientLocalDataSource({Map<String, ClientModel>? clientsById})
    : clientsById = clientsById ?? <String, ClientModel>{};

  final List<ClientModel> insertedClients = <ClientModel>[];
  final List<ClientModel> updatedClients = <ClientModel>[];
  final List<String> softDeletedClientIds = <String>[];

  @override
  Future<void> insertClient(ClientModel client) async {
    clientsById[client.id] = client;
    insertedClients.add(client);
  }

  @override
  Future<void> updateClient(ClientModel client) async {
    clientsById[client.id] = client;
    updatedClients.add(client);
  }

  @override
  Future<ClientModel?> getClientById(String clientId) async => clientsById[clientId];

  @override
  Future<void> softDeleteClient(String clientId) async {
    softDeletedClientIds.add(clientId);
  }
}

class FakePolicyLocalDataSource extends PolicyLocalDataSource {
  FakePolicyLocalDataSource({Map<String, PolicyModel>? policiesById})
    : policiesById = policiesById ?? <String, PolicyModel>{};

  Map<String, PolicyModel> policiesById;
  final List<PolicyModel> insertedPolicies = <PolicyModel>[];
  final List<PolicyModel> updatedPolicies = <PolicyModel>[];
  final List<String> softDeletedPolicyIds = <String>[];
  final List<PolicyRenewalUpdate> renewalUpdates = <PolicyRenewalUpdate>[];

  @override
  Future<void> insertPolicy(PolicyModel policy) async {
    policiesById[policy.id] = policy;
    insertedPolicies.add(policy);
  }

  @override
  Future<void> updatePolicy(PolicyModel policy) async {
    policiesById[policy.id] = policy;
    updatedPolicies.add(policy);
  }

  @override
  Future<PolicyModel?> getPolicyById(String policyId) async => policiesById[policyId];

  @override
  Future<void> softDeletePolicy(String policyId) async {
    softDeletedPolicyIds.add(policyId);
  }

  @override
  Future<void> updateRenewalStatus({
    required String policyId,
    required String renewalStatus,
    String? policyStatus,
  }) async {
    renewalUpdates.add(
      PolicyRenewalUpdate(
        policyId: policyId,
        renewalStatus: renewalStatus,
        policyStatus: policyStatus,
      ),
    );
  }
}

class PolicyRenewalUpdate {
  const PolicyRenewalUpdate({
    required this.policyId,
    required this.renewalStatus,
    this.policyStatus,
  });

  final String policyId;
  final String renewalStatus;
  final String? policyStatus;
}

class FakeReminderLocalDataSource extends ReminderLocalDataSource {
  FakeReminderLocalDataSource({
    Map<String, ReminderModel>? remindersById,
    Map<String, List<ReminderModel>>? remindersByPolicy,
  }) : remindersById = remindersById ?? <String, ReminderModel>{},
       remindersByPolicy = remindersByPolicy ?? <String, List<ReminderModel>>{};

  Map<String, ReminderModel> remindersById;
  Map<String, List<ReminderModel>> remindersByPolicy;
  final List<List<ReminderModel>> insertedReminderBatches = <List<ReminderModel>>[];
  final List<String> completedReminderIds = <String>[];
  final List<String> renewedReminderIds = <String>[];
  final List<String> softDeletedPolicyIds = <String>[];

  @override
  Future<void> insertReminders(List<ReminderModel> reminders) async {
    insertedReminderBatches.add(reminders);
    for (final reminder in reminders) {
      remindersById[reminder.id] = reminder;
      remindersByPolicy.putIfAbsent(reminder.policyId, () => <ReminderModel>[]).add(reminder);
    }
  }

  @override
  Future<ReminderModel?> getReminderById(String reminderId) async => remindersById[reminderId];

  @override
  Future<List<ReminderModel>> getRemindersByPolicy(String policyId) async {
    return remindersByPolicy[policyId] ?? <ReminderModel>[];
  }

  @override
  Future<void> softDeleteByPolicy(String policyId) async {
    softDeletedPolicyIds.add(policyId);
  }

  @override
  Future<void> markReminderCompleted(String reminderId) async {
    completedReminderIds.add(reminderId);
  }

  @override
  Future<void> markReminderRenewed(String reminderId) async {
    renewedReminderIds.add(reminderId);
  }

  @override
  Future<List<ReminderModel>> getRemindersByClient(String clientId) async {
    return remindersById.values.where((item) => item.clientId == clientId).toList();
  }
}

class FakeFollowUpLocalDataSource extends FollowUpLocalDataSource {
  FakeFollowUpLocalDataSource({Map<String, FollowUpModel>? followUpsById})
    : followUpsById = followUpsById ?? <String, FollowUpModel>{};

  Map<String, FollowUpModel> followUpsById;
  final List<FollowUpModel> insertedFollowUps = <FollowUpModel>[];
  final List<FollowUpModel> updatedFollowUps = <FollowUpModel>[];
  final List<String> softDeletedFollowUpIds = <String>[];
  final List<String> completedFollowUpIds = <String>[];
  final List<RescheduleRequest> rescheduleRequests = <RescheduleRequest>[];

  @override
  Future<void> insertFollowUp(FollowUpModel followUp) async {
    followUpsById[followUp.id] = followUp;
    insertedFollowUps.add(followUp);
  }

  @override
  Future<void> updateFollowUp(FollowUpModel followUp) async {
    followUpsById[followUp.id] = followUp;
    updatedFollowUps.add(followUp);
  }

  @override
  Future<FollowUpModel?> getFollowUpById(String followUpId) async {
    return followUpsById[followUpId];
  }

  @override
  Future<void> softDeleteFollowUp(String followUpId) async {
    softDeletedFollowUpIds.add(followUpId);
  }

  @override
  Future<void> markFollowUpCompleted(String followUpId) async {
    completedFollowUpIds.add(followUpId);
  }

  @override
  Future<void> rescheduleFollowUp({
    required String followUpId,
    required int scheduledAt,
  }) async {
    rescheduleRequests.add(
      RescheduleRequest(followUpId: followUpId, scheduledAt: scheduledAt),
    );
  }
}

class RescheduleRequest {
  const RescheduleRequest({required this.followUpId, required this.scheduledAt});

  final String followUpId;
  final int scheduledAt;
}

class FakeReminderGeneratorService extends ReminderGeneratorService {
  FakeReminderGeneratorService(this.reminders);

  final List<ReminderModel> reminders;
  final List<PolicyModel> generatedForPolicies = <PolicyModel>[];

  @override
  List<ReminderModel> generateForPolicy(PolicyModel policy) {
    generatedForPolicies.add(policy);
    return reminders;
  }
}

class FakeReminderSchedulerService extends ReminderSchedulerService {
  FakeReminderSchedulerService();

  final List<ScheduleRequest> scheduleRequests = <ScheduleRequest>[];
  final List<List<ReminderModel>> cancelledReminderBatches = <List<ReminderModel>>[];

  @override
  Future<void> scheduleReminders({
    required List<ReminderModel> reminders,
    required String clientName,
    required String policyNumber,
    required String companyName,
  }) async {
    scheduleRequests.add(
      ScheduleRequest(
        reminders: reminders,
        clientName: clientName,
        policyNumber: policyNumber,
        companyName: companyName,
      ),
    );
  }

  @override
  Future<void> cancelReminders(List<ReminderModel> reminders) async {
    cancelledReminderBatches.add(reminders);
  }
}

class ScheduleRequest {
  const ScheduleRequest({
    required this.reminders,
    required this.clientName,
    required this.policyNumber,
    required this.companyName,
  });

  final List<ReminderModel> reminders;
  final String clientName;
  final String policyNumber;
  final String companyName;
}
