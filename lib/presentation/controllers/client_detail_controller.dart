import 'package:get/get.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/client_timeline_item.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_ups_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_by_client_usecase.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailController extends GetxController {
  ClientDetailController({
    required GetClientDetailsUseCase getClientDetailsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required GetFollowUpsByClientUseCase getFollowUpsByClientUseCase,
    required GetPoliciesByClientUseCase getPoliciesByClientUseCase,
    required GetRemindersByClientUseCase getRemindersByClientUseCase,
  }) : _getClientDetailsUseCase = getClientDetailsUseCase,
       _deleteClientUseCase = deleteClientUseCase,
       _getFollowUpsByClientUseCase = getFollowUpsByClientUseCase,
       _getPoliciesByClientUseCase = getPoliciesByClientUseCase,
       _getRemindersByClientUseCase = getRemindersByClientUseCase;

  final GetClientDetailsUseCase _getClientDetailsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final GetFollowUpsByClientUseCase _getFollowUpsByClientUseCase;
  final GetPoliciesByClientUseCase _getPoliciesByClientUseCase;
  final GetRemindersByClientUseCase _getRemindersByClientUseCase;

  final client = Rxn<Client>();
  final timelineItems = <ClientTimelineItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final String clientId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    clientId = args is Client ? args.id : args as String;
    loadClient();
  }

  Future<void> loadClient() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      client.value = await _getClientDetailsUseCase(clientId);
      if (client.value == null) {
        errorMessage.value = 'Client not found';
      } else {
        await _loadTimeline();
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient() async {
    await _deleteClientUseCase(clientId);
    Get.back(result: true);
  }

  Future<void> callClient() async {
    final mobile = client.value?.mobile;
    if (mobile == null || mobile.isEmpty) {
      throw Exception('Mobile number not available');
    }
    final uri = Uri.parse('tel:$mobile');
    if (!await launchUrl(uri)) {
      throw Exception('Unable to open the dialer');
    }
  }

  Future<void> whatsappClient() async {
    final mobile = client.value?.mobile;
    if (mobile == null || mobile.isEmpty) {
      throw Exception('Mobile number not available');
    }
    final uri = Uri.parse('https://wa.me/91$mobile');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open WhatsApp');
    }
  }

  Future<void> _loadTimeline() async {
    final policies = await _getPoliciesByClientUseCase(clientId);
    final reminders = await _getRemindersByClientUseCase(clientId);
    final followUps = await _getFollowUpsByClientUseCase(clientId);
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
