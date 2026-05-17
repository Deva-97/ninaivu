import 'package:get/get.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminder_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_completed_usecase.dart';

class ReminderDetailController extends GetxController {
  ReminderDetailController({
    required GetReminderByIdUseCase getReminderByIdUseCase,
    required MarkReminderCompletedUseCase markReminderCompletedUseCase,
  }) : _getReminderByIdUseCase = getReminderByIdUseCase,
       _markReminderCompletedUseCase = markReminderCompletedUseCase;

  final GetReminderByIdUseCase _getReminderByIdUseCase;
  final MarkReminderCompletedUseCase _markReminderCompletedUseCase;

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
}
