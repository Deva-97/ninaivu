import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/utils/follow_up_status_helper.dart';

void main() {
  group('FollowUpStatusHelper', () {
    test('marks pending past follow-up as missed', () {
      final now = DateTime(2026, 5, 16, 12);

      final isMissed = FollowUpStatusHelper.isMissed(
        status: 'Pending',
        followUpDateTime: DateTime(2026, 5, 16, 9).millisecondsSinceEpoch,
        now: now,
      );

      expect(isMissed, isTrue);
    });

    test('does not mark completed follow-up as missed', () {
      final now = DateTime(2026, 5, 16, 12);

      final isMissed = FollowUpStatusHelper.isMissed(
        status: 'Completed',
        followUpDateTime: DateTime(2026, 5, 16, 9).millisecondsSinceEpoch,
        now: now,
      );

      expect(isMissed, isFalse);
    });
  });
}
