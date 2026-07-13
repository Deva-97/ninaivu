class ExtractedPolicyData {
  const ExtractedPolicyData({
    this.policyNumber,
    this.companyName,
    this.insuranceType,
    this.policyHolderName,
    this.startDateMs,
    this.endDateMs,
    this.premiumAmount,
    this.paymentFrequency,
    this.vehicleNumber,
    this.vehicleModel,
    this.status,
    required this.rawText,
    this.warnings,
    this.parseConfidence,
  });

  final String? policyNumber;
  final String? companyName;
  final String? insuranceType;
  final String? policyHolderName;
  final int? startDateMs;
  final int? endDateMs;
  final double? premiumAmount;
  final String? paymentFrequency;
  final String? vehicleNumber;
  final String? vehicleModel;
  final String? status;
  final String rawText;
  final List<String>? warnings;
  final double? parseConfidence;

  bool get hasStructuredData =>
      policyNumber != null ||
      companyName != null ||
      insuranceType != null ||
      policyHolderName != null ||
      startDateMs != null ||
      endDateMs != null ||
      premiumAmount != null ||
      paymentFrequency != null ||
      vehicleNumber != null ||
      vehicleModel != null ||
      status != null;

  int get structuredFieldCount => [
    policyNumber,
    companyName,
    insuranceType,
    policyHolderName,
    startDateMs,
    endDateMs,
    premiumAmount,
    paymentFrequency,
    vehicleNumber,
    vehicleModel,
    status,
  ].where((value) => value != null).length;

  bool get hasWarnings => warnings != null && warnings!.isNotEmpty;
}
