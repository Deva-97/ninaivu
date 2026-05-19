import 'package:get/get.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_missed_follow_ups_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_today_follow_ups_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/mark_follow_up_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/reschedule_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/mark_reminder_renewed_usecase.dart';

class TodaysWorkController extends GetxController {
  TodaysWorkController({
    required GetMissedFollowUpsUseCase getMissedFollowUpsUseCase,
    required GetRemindersUseCase getRemindersUseCase,
    required GetTodayFollowUpsUseCase getTodayFollowUpsUseCase,
    required MarkFollowUpCompletedUseCase markFollowUpCompletedUseCase,
    required MarkReminderCompletedUseCase markReminderCompletedUseCase,
    required MarkReminderRenewedUseCase markReminderRenewedUseCase,
    required RescheduleFollowUpUseCase rescheduleFollowUpUseCase,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
  }) : _getMissedFollowUpsUseCase = getMissedFollowUpsUseCase,
       _getRemindersUseCase = getRemindersUseCase,
       _getTodayFollowUpsUseCase = getTodayFollowUpsUseCase,
       _markFollowUpCompletedUseCase = markFollowUpCompletedUseCase,
       _markReminderCompletedUseCase = markReminderCompletedUseCase,
       _markReminderRenewedUseCase = markReminderRenewedUseCase,
       _rescheduleFollowUpUseCase = rescheduleFollowUpUseCase,
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource();

  final GetMissedFollowUpsUseCase _getMissedFollowUpsUseCase;
  final GetRemindersUseCase _getRemindersUseCase;
  final GetTodayFollowUpsUseCase _getTodayFollowUpsUseCase;
  final MarkFollowUpCompletedUseCase _markFollowUpCompletedUseCase;
  final MarkReminderCompletedUseCase _markReminderCompletedUseCase;
  final MarkReminderRenewedUseCase _markReminderRenewedUseCase;
  final RescheduleFollowUpUseCase _rescheduleFollowUpUseCase;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;

  final renewalsToday = <Reminder>[].obs;
  final upcomingRenewals = <Reminder>[].obs;
  final followUpsToday = <FollowUp>[].obs;
  final missedFollowUps = <FollowUp>[].obs;
  final pendingSyncCount = 0.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      renewalsToday.assignAll(await _getRemindersUseCase(filter: 'today'));
      final upcomingItems = await _getRemindersUseCase(filter: 'upcoming7days');
      final todayIds = renewalsToday.map((item) => item.id).toSet();
      upcomingRenewals.assignAll(
        upcomingItems.where((item) => !todayIds.contains(item.id)).toList(),
      );
      followUpsToday.assignAll(await _getTodayFollowUpsUseCase());
      missedFollowUps.assignAll(await _getMissedFollowUpsUseCase());
      pendingSyncCount.value = await _syncQueueLocalDataSource.countPendingItems();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markReminderCompleted(String reminderId) async {
    await _markReminderCompletedUseCase(reminderId);
    await loadData();
  }

  Future<void> markReminderRenewed(String reminderId) async {
    await _markReminderRenewedUseCase(reminderId);
    await loadData();
  }

  Future<void> markFollowUpCompleted(String followUpId) async {
    await _markFollowUpCompletedUseCase(followUpId);
    await loadData();
  }

  Future<void> rescheduleFollowUp({
    required String followUpId,
    required int scheduledAt,
  }) async {
    await _rescheduleFollowUpUseCase(
      followUpId: followUpId,
      scheduledAt: scheduledAt,
    );
    await loadData();
  }
}
