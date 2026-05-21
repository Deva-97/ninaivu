import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/core/services/profile_image_service.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/client_timeline_item.dart';
import 'package:ninaivu/domain/usecases/clients/update_client_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_ups_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_by_client_usecase.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ClientDetailController extends GetxController {
  ClientDetailController({
    required GetClientDetailsUseCase getClientDetailsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required GetFollowUpsByClientUseCase getFollowUpsByClientUseCase,
    required GetPoliciesByClientUseCase getPoliciesByClientUseCase,
    required GetRemindersByClientUseCase getRemindersByClientUseCase,
    required UpdateClientUseCase updateClientUseCase,
    required CommunicationService communicationService,
    required ProfileImageService profileImageService,
  }) : _getClientDetailsUseCase = getClientDetailsUseCase,
       _deleteClientUseCase = deleteClientUseCase,
       _getFollowUpsByClientUseCase = getFollowUpsByClientUseCase,
       _getPoliciesByClientUseCase = getPoliciesByClientUseCase,
       _getRemindersByClientUseCase = getRemindersByClientUseCase,
       _updateClientUseCase = updateClientUseCase,
       _communicationService = communicationService,
       _profileImageService = profileImageService;

  final GetClientDetailsUseCase _getClientDetailsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final GetFollowUpsByClientUseCase _getFollowUpsByClientUseCase;
  final GetPoliciesByClientUseCase _getPoliciesByClientUseCase;
  final GetRemindersByClientUseCase _getRemindersByClientUseCase;
  final UpdateClientUseCase _updateClientUseCase;
  final CommunicationService _communicationService;
  final ProfileImageService _profileImageService;

  final client = Rxn<Client>();
  final timelineItems = <ClientTimelineItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final String clientId;
  int _requestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    clientId = args is Client ? args.id : args as String;
    loadClient();
  }

  Future<void> loadClient() async {
    final requestVersion = ++_requestVersion;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final loadedClient = await _getClientDetailsUseCase(clientId);
      if (requestVersion != _requestVersion || isClosed) {
        return;
      }

      client.value = loadedClient;
      if (client.value == null) {
        errorMessage.value = 'Client not found';
      } else {
        await _loadTimeline(requestVersion: requestVersion);
      }
    } catch (e) {
      if (requestVersion == _requestVersion && !isClosed) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (requestVersion == _requestVersion && !isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteClient() async {
    await _deleteClientUseCase(clientId);
    Get.back(result: true);
  }

  Future<void> callClient() async {
    await _communicationService.openDialer(client.value?.mobile);
  }

  Future<void> whatsappClient() async {
    await _communicationService.openWhatsAppChat(client.value?.mobile);
  }

  Future<void> updateProfileImage() async {
    final existing = client.value;
    if (existing == null) {
      return;
    }
    final path = await _profileImageService.pickImagePath();
    if (path == null) {
      return;
    }
    await _updateClientUseCase(
      ClientModel.fromEntity(existing).copyWith(profileImagePath: path),
    );
    await loadClient();
  }

  Future<void> _loadTimeline({required int requestVersion}) async {
    final results = await Future.wait([
      _getPoliciesByClientUseCase(clientId),
      _getRemindersByClientUseCase(clientId),
      _getFollowUpsByClientUseCase(clientId),
    ]);

    if (requestVersion != _requestVersion || isClosed) {
      return;
    }

    final policies = results[0] as List<dynamic>;
    final reminders = results[1] as List<dynamic>;
    final followUps = results[2] as List<dynamic>;
    final items = <ClientTimelineItem>[
      ...policies.map(
        (policy) => ClientTimelineItem(
          id: policy.id,
          type: 'policy',
          title: policy.policyNumber,
          subtitle: '${policy.companyName} • ${policy.insuranceType}',
          status: policy.status,
          dateTimeMillis: policy.updatedAt,
          routeName: AppRoutes.policyDetails,
          routeArgument: policy.id,
        ),
      ),
      ...reminders.map(
        (reminder) => ClientTimelineItem(
          id: reminder.id,
          type: 'reminder',
          title: reminder.policyNumber ?? 'Policy reminder',
          subtitle: reminder.reminderType,
          status: reminder.status,
          dateTimeMillis: reminder.reminderDateTime,
          routeName: AppRoutes.reminderDetails,
          routeArgument: reminder.id,
        ),
      ),
      ...followUps.map(
        (followUp) => ClientTimelineItem(
          id: followUp.id,
          type: 'follow_up',
          title: followUp.type,
          subtitle: followUp.remarks ?? 'No remarks',
          status: followUp.status,
          dateTimeMillis: followUp.followUpDateTime,
          routeName: AppRoutes.followUpDetails,
          routeArgument: followUp.id,
        ),
      ),
    ];
    items.sort((a, b) => b.dateTimeMillis.compareTo(a.dateTimeMillis));
    timelineItems.assignAll(items);
  }
}
