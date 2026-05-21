import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminder_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_renewed_usecase.dart';

class ReminderDetailController extends GetxController {
  ReminderDetailController({
    required GetReminderByIdUseCase getReminderByIdUseCase,
    required MarkReminderCompletedUseCase markReminderCompletedUseCase,
    required MarkReminderRenewedUseCase markReminderRenewedUseCase,
    required CommunicationService communicationService,
  }) : _getReminderByIdUseCase = getReminderByIdUseCase,
       _markReminderCompletedUseCase = markReminderCompletedUseCase,
       _markReminderRenewedUseCase = markReminderRenewedUseCase,
       _communicationService = communicationService;

  final GetReminderByIdUseCase _getReminderByIdUseCase;
  final MarkReminderCompletedUseCase _markReminderCompletedUseCase;
  final MarkReminderRenewedUseCase _markReminderRenewedUseCase;
  final CommunicationService _communicationService;

  final reminder = Rxn<Reminder>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  late final String reminderId;

  @override
  void onInit() {
    super.onInit();
    reminderId = (Get.arguments as String?) ?? '';
    loadReminder();
  }

  Future<void> loadReminder() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      reminder.value = await _getReminderByIdUseCase(reminderId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markCompleted() async {
    isUpdating.value = true;
    try {
      await _markReminderCompletedUseCase(reminderId);
      await loadReminder();
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Unable to update',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> markRenewed() async {
    isUpdating.value = true;
    try {
      await _markReminderRenewedUseCase(reminderId);
      await loadReminder();
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Unable to update',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> callClient() async {
    await _communicationService.openDialer(reminder.value?.clientMobile);
  }

  Future<void> whatsappClient() async {
    await _communicationService.openWhatsAppChat(reminder.value?.clientMobile);
  }
}
