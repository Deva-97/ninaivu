class PolicyValidator {
  PolicyValidator._();

  static String? validateDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!endDate.isAfter(startDate)) {
      return 'Policy end date must be after start date.';
    }
    return null;
  }
}
