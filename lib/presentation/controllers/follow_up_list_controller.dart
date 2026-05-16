import 'package:get/get.dart';
import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/delete_follow_up_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/get_follow_ups_usecase.dart';

class FollowUpListController extends GetxController {
  FollowUpListController({
    required GetFollowUpsUseCase getFollowUpsUseCase,
    required DeleteFollowUpUseCase deleteFollowUpUseCase,
  }) : _getFollowUpsUseCase = getFollowUpsUseCase,
       _deleteFollowUpUseCase = deleteFollowUpUseCase;

  final GetFollowUpsUseCase _getFollowUpsUseCase;
  final DeleteFollowUpUseCase _deleteFollowUpUseCase;

  final followUps = <FollowUp>[].obs;
  final selectedFilter = 'today'.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      selectedFilter.value = args['filter'] as String? ?? 'today';
    }
    loadFollowUps();
  }

  Future<void> loadFollowUps({String? filter}) async {
    if (filter != null) {
      selectedFilter.value = filter;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      followUps.assignAll(
        await _getFollowUpsUseCase(filter: selectedFilter.value),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFollowUp(String followUpId) async {
    await _deleteFollowUpUseCase(followUpId);
    await loadFollowUps();
  }
}
