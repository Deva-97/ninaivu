class FollowUpStatusHelper {
  FollowUpStatusHelper._();

  static bool isMissed({
    required String status,
    required int followUpDateTime,
    required DateTime now,
  }) {
    return status == 'Pending' && followUpDateTime < now.millisecondsSinceEpoch;
  }
}
