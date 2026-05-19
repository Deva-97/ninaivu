import 'package:ninaivu/domain/entities/follow_up.dart';

abstract class FollowUpRepository {
  Future<FollowUp> addFollowUp(FollowUp followUp);
  Future<FollowUp> updateFollowUp(FollowUp followUp);
  Future<void> deleteFollowUp(String followUpId);
  Future<void> markFollowUpCompleted(String followUpId);
  Future<List<FollowUp>> getTodayFollowUps();
  Future<List<FollowUp>> getMissedFollowUps();
  Future<List<FollowUp>> getUpcomingFollowUps({int withinDays = 30});
  Future<List<FollowUp>> getFollowUps({
    String filter = 'today',
  });
  Future<FollowUp?> getFollowUpById(String followUpId);
  Future<void> rescheduleFollowUp({
    required String followUpId,
    required int scheduledAt,
  });
  Future<List<FollowUp>> getFollowUpsByClient(
    String clientId, {
    String? filter,
  });
}
