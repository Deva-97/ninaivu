import 'package:get/get.dart';
import 'package:ninaivu/data/repositories/follow_up_repository_impl.dart';
import 'package:ninaivu/data/repositories/reminder_repository_impl.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_missed_follow_ups_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_today_follow_ups_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/mark_follow_up_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/reschedule_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_renewed_usecase.dart';
import 'package:ninaivu/presentation/controllers/todays_work_controller.dart';

class TodaysWorkBinding extends Bindings {
  @override
  void dependencies() {
    final reminderRepository = ReminderRepositoryImpl();
    final followUpRepository = FollowUpRepositoryImpl();
    Get.lazyPut(
      () => TodaysWorkController(
        getMissedFollowUpsUseCase: GetMissedFollowUpsUseCase(followUpRepository),
        getRemindersUseCase: GetRemindersUseCase(reminderRepository),
        getTodayFollowUpsUseCase: GetTodayFollowUpsUseCase(followUpRepository),
        markFollowUpCompletedUseCase: MarkFollowUpCompletedUseCase(followUpRepository),
        markReminderCompletedUseCase: MarkReminderCompletedUseCase(reminderRepository),
        markReminderRenewedUseCase: MarkReminderRenewedUseCase(reminderRepository),
        rescheduleFollowUpUseCase: RescheduleFollowUpUseCase(followUpRepository),
      ),
    );
  }
}
