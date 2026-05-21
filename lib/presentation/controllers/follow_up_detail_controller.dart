import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/usecases/follow_ups/delete_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_up_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/mark_follow_up_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/reschedule_follow_up_usecase.dart';

class FollowUpDetailController extends GetxController {
  FollowUpDetailController({
    required GetFollowUpByIdUseCase getFollowUpByIdUseCase,
    required DeleteFollowUpUseCase deleteFollowUpUseCase,
    required MarkFollowUpCompletedUseCase markFollowUpCompletedUseCase,
    required RescheduleFollowUpUseCase rescheduleFollowUpUseCase,
    required CommunicationService communicationService,
  }) : _getFollowUpByIdUseCase = getFollowUpByIdUseCase,
       _deleteFollowUpUseCase = deleteFollowUpUseCase,
       _markFollowUpCompletedUseCase = markFollowUpCompletedUseCase,
       _rescheduleFollowUpUseCase = rescheduleFollowUpUseCase,
       _communicationService = communicationService;

  final GetFollowUpByIdUseCase _getFollowUpByIdUseCase;
  final DeleteFollowUpUseCase _deleteFollowUpUseCase;
  final MarkFollowUpCompletedUseCase _markFollowUpCompletedUseCase;
  final RescheduleFollowUpUseCase _rescheduleFollowUpUseCase;
  final CommunicationService _communicationService;

  final followUp = Rxn<FollowUp>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  late final String followUpId;

  @override
  void onInit() {
    super.onInit();
    followUpId = (Get.arguments as String?) ?? '';
    loadFollowUp();
  }

  Future<void> loadFollowUp() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      followUp.value = await _getFollowUpByIdUseCase(followUpId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markCompleted() async {
    isUpdating.value = true;
    try {
      await _markFollowUpCompletedUseCase(followUpId);
      await loadFollowUp();
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

  Future<void> deleteFollowUp() async {
    isUpdating.value = true;
    try {
      await _deleteFollowUpUseCase(followUpId);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Unable to delete',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> reschedule(int scheduledAt) async {
    isUpdating.value = true;
    try {
      await _rescheduleFollowUpUseCase(
        followUpId: followUpId,
        scheduledAt: scheduledAt,
      );
      await loadFollowUp();
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Unable to reschedule',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> callClient() async {
    await _communicationService.openDialer(followUp.value?.clientMobile);
  }

  Future<void> whatsappClient() async {
    await _communicationService.openWhatsAppChat(followUp.value?.clientMobile);
  }
}
