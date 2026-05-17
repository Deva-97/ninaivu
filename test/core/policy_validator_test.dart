import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/validation/policy_validator.dart';

void main() {
  group('PolicyValidator', () {
    test('accepts valid date range', () {
      final result = PolicyValidator.validateDateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      );

      expect(result, isNull);
    });

    test('rejects same-day or earlier end date', () {
      final result = PolicyValidator.validateDateRange(
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 10),
      );

      expect(result, 'Policy end date must be after start date.');
    });
  });
}
