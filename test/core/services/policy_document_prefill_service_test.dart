import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/services/policy_document_prefill_service.dart';

void main() {
  const service = PolicyDocumentPrefillService();
  final now = DateTime(2026, 5, 22);

  group('PolicyDocumentPrefillService', () {
    test('extracts safe direct fields for a car policy', () {
      const rawText = '''
Private Car Package Policy
Company Name : ICICI Lombard General Insurance Company Limited
Policy Number : 3001 / MOT / PC-12345678 / 00 / 000
Policy Holder Name : Arun Kumar
Policy Start Date : 01/04/2026
Policy End Date : 31/03/2027
Vehicle Number : TN 10 AB 1234
Make / Model : HYUNDAI CRETA SX (O) 1.5 PETROL
Total Premium : Rs. 13,105.08
''';

      final result = service.parse(rawText, now: now);

      expect(result.insuranceType, 'Car');
      expect(
        result.companyName,
        'ICICI Lombard General Insurance Company Limited',
      );
      expect(result.policyNumber, '3001/MOT/PC-12345678/00/000');
      expect(result.policyHolderName, 'Arun Kumar');
      expect(result.startDateMs, DateTime(2026, 4, 1).millisecondsSinceEpoch);
      expect(result.endDateMs, DateTime(2027, 3, 31).millisecondsSinceEpoch);
      expect(result.vehicleNumber, 'TN10AB1234');
      expect(result.vehicleModel, 'HYUNDAI CRETA SX (O) 1.5 PETROL');
      expect(result.premiumAmount, 13105.08);
      expect(result.status, 'Active');
      expect(result.warnings, isNull);
      expect(result.parseConfidence, isNull);
    });

    test('extracts split-line values for bike policy documents', () {
      const rawText = '''
Two Wheeler Package Policy
Insured Name
Meena Krishnan
Vehicle Model
TVS Jupiter ZX
Vehicle Number
KA-05-MN-1234
Total Premium Payable
Rs. 5,876/-
''';

      final result = service.parse(rawText, now: now);

      expect(result.insuranceType, 'Bike');
      expect(result.policyHolderName, 'Meena Krishnan');
      expect(result.vehicleModel, 'TVS Jupiter ZX');
      expect(result.vehicleNumber, 'KA05MN1234');
      expect(result.premiumAmount, 5876);
      expect(result.warnings, isNull);
    });

    test('extracts health policy dates and premium from direct labels', () {
      const rawText = '''
Family Floater Health Insurance
Insured Member : Priya Raman
Policy Period : 01/04/2026 to 31/03/2027
Total Premium Payable : 12,345.00
''';

      final result = service.parse(rawText, now: now);

      expect(result.insuranceType, 'Health');
      expect(result.policyHolderName, 'Priya Raman');
      expect(result.startDateMs, DateTime(2026, 4, 1).millisecondsSinceEpoch);
      expect(result.endDateMs, DateTime(2027, 3, 31).millisecondsSinceEpoch);
      expect(result.premiumAmount, 12345);
      expect(result.status, 'Active');
    });

    test('extracts life policy payment mode and maturity dates', () {
      const rawText = '''
Life Insurance Corporation of India
Proposer Name - Rakesh Nair
Policy No : LIC-4455667788
Date of Commencement : 01 Jan 2026
Date of Maturity : 01-January-2046
Premium Mode : Half Yearly
Modal Premium : 24,000.00
''';

      final result = service.parse(rawText, now: now);

      expect(result.insuranceType, 'Life');
      expect(result.policyHolderName, 'Rakesh Nair');
      expect(result.policyNumber, 'LIC-4455667788');
      expect(result.startDateMs, DateTime(2026, 1, 1).millisecondsSinceEpoch);
      expect(result.endDateMs, DateTime(2046, 1, 1).millisecondsSinceEpoch);
      expect(result.paymentFrequency, 'Half-yearly');
      expect(result.premiumAmount, 24000);
    });

    test('prefers term keyword over broader life keyword', () {
      const rawText = '''
HDFC Life Term Insurance
Life Assured : John Kumar
Policy Number : TERM123456789
Annual Premium : 18,500
''';

      final result = service.parse(rawText, now: now);

      expect(result.insuranceType, 'Term');
      expect(result.policyHolderName, 'John Kumar');
      expect(result.policyNumber, 'TERM123456789');
      expect(result.premiumAmount, 18500);
    });

    test(
      'leaves conflicting direct premium values empty and records a warning',
      () {
        const rawText = '''
Private Car Package Policy
Policy Number : CAR12345
Total Premium : 13,105.08
Premium Amount : 10,999.00
''';

        final result = service.parse(rawText, now: now);

        expect(result.insuranceType, 'Car');
        expect(result.policyNumber, 'CAR12345');
        expect(result.premiumAmount, isNull);
        expect(result.hasWarnings, isTrue);
        expect(
          result.warnings,
          contains('Conflicting premium amount values found.'),
        );
      },
    );

    test('returns raw text with no structured fields for noisy documents', () {
      const rawText = '''
Welcome to your insurance document
Please keep this paper safe for future use
Customer care contact details inside
''';

      final result = service.parse(rawText, now: now);

      expect(result.hasStructuredData, isFalse);
      expect(result.rawText, rawText.trim());
      expect(result.hasWarnings, isTrue);
      expect(result.warnings, contains('No reliable structured values found.'));
    });
  });
}
