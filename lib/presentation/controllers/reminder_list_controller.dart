import 'package:get/get.dart';
import 'package:insurance_reminders/domain/entities/reminder.dart';
import 'package:insurance_reminders/domain/usecases/reminders/get_reminders_usecase.dart';

class ReminderListController extends GetxController {
  ReminderListController({
    required GetRemindersUseCase getRemindersUseCase,
  }) : _getRemindersUseCase = getRemindersUseCase;

  final GetRemindersUseCase _getRemindersUseCase;

  final reminders = <Reminder>[].obs;
  final selectedFilter = 'today'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> loadReminders({String? filter}) async {
    if (filter != null) {
      selectedFilter.value = filter;
    }
    isLoading.value = true;
    errorMessage.value = null;

    try {
      reminders.assignAll(
        await _getRemindersUseCase(filter: selectedFilter.value),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      selectedFilter.value = args['filter'] as String? ?? 'today';
    }
    loadReminders();
  }
}
