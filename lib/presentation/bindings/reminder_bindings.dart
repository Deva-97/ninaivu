import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/data/repositories/reminder_repository_impl.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminder_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_renewed_usecase.dart';
import 'package:ninaivu/presentation/controllers/reminder_detail_controller.dart';
import 'package:ninaivu/presentation/controllers/reminder_list_controller.dart';

class ReminderListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ReminderRepositoryImpl();
    Get.lazyPut(
      () => ReminderListController(
        getRemindersUseCase: GetRemindersUseCase(repository),
      ),
    );
  }
}

class ReminderDetailBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ReminderRepositoryImpl();
    Get.lazyPut(
      () => ReminderDetailController(
        getReminderByIdUseCase: GetReminderByIdUseCase(repository),
        markReminderCompletedUseCase: MarkReminderCompletedUseCase(repository),
        markReminderRenewedUseCase: MarkReminderRenewedUseCase(repository),
        communicationService: CommunicationService(),
      ),
    );
  }
}
