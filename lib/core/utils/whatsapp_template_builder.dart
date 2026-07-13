import 'package:intl/intl.dart';

class WhatsAppTemplateData {
  const WhatsAppTemplateData({
    this.clientName,
    this.mobile,
    this.policyNumber,
    this.companyName,
    this.insuranceType,
    this.expiryDateMillis,
    this.premiumAmount,
    this.agentName,
    this.agentMobile,
    this.followUpType,
  });

  final String? clientName;
  final String? mobile;
  final String? policyNumber;
  final String? companyName;
  final String? insuranceType;
  final int? expiryDateMillis;
  final double? premiumAmount;
  final String? agentName;
  final String? agentMobile;
  final String? followUpType;
}

enum WhatsAppTemplateType {
  policyRenewalReminder,
  paymentPending,
  documentCollection,
  followUpReminder,
  thankYouAfterRenewal,
}

class WhatsAppTemplateBuilder {
  WhatsAppTemplateBuilder._();

  static const Map<WhatsAppTemplateType, String> labels = {
    WhatsAppTemplateType.policyRenewalReminder: 'Policy Renewal Reminder',
    WhatsAppTemplateType.paymentPending: 'Payment Pending',
    WhatsAppTemplateType.documentCollection: 'Document Collection',
    WhatsAppTemplateType.followUpReminder: 'Follow-up Reminder',
    WhatsAppTemplateType.thankYouAfterRenewal: 'Thank You After Renewal',
  };

  // Builds a concise professional WhatsApp message for common insurance actions.
  static String build({
    required WhatsAppTemplateType template,
    required WhatsAppTemplateData data,
  }) {
    final name = data.clientName?.trim().isNotEmpty == true
        ? data.clientName!.trim()
        : 'Sir/Madam';
    final policyBits = <String>[
      if ((data.policyNumber ?? '').trim().isNotEmpty)
        'Policy No: ${data.policyNumber!.trim()}',
      if ((data.companyName ?? '').trim().isNotEmpty)
        'Company: ${data.companyName!.trim()}',
      if ((data.insuranceType ?? '').trim().isNotEmpty)
        'Type: ${data.insuranceType!.trim()}',
      if (data.expiryDateMillis != null)
        'Expiry: ${DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(data.expiryDateMillis!))}',
      if (data.premiumAmount != null)
        'Premium: Rs. ${data.premiumAmount!.toStringAsFixed(0)}',
    ];
    final sender = _senderLine(data);

    switch (template) {
      case WhatsAppTemplateType.policyRenewalReminder:
        return 'Dear $name,\n'
            'This is a reminder that your insurance renewal is coming up.\n'
            '${policyBits.join('\n')}\n'
            'Please let us know a convenient time to assist you with renewal.\n'
            '$sender';
      case WhatsAppTemplateType.paymentPending:
        return 'Dear $name,\n'
            'A payment is pending for your insurance policy.\n'
            '${policyBits.join('\n')}\n'
            'Kindly share a suitable time so we can help complete the payment.\n'
            '$sender';
      case WhatsAppTemplateType.documentCollection:
        return 'Dear $name,\n'
            'We need a few documents to proceed with your insurance work.\n'
            '${policyBits.join('\n')}\n'
            'Please share the documents at your convenience or contact us for support.\n'
            '$sender';
      case WhatsAppTemplateType.followUpReminder:
        return 'Dear $name,\n'
            'This is a follow-up regarding your insurance ${data.followUpType?.toLowerCase() ?? 'request'}.\n'
            '${policyBits.join('\n')}\n'
            'Please let us know how you would like to proceed.\n'
            '$sender';
      case WhatsAppTemplateType.thankYouAfterRenewal:
        return 'Dear $name,\n'
            'Thank you for renewing your insurance policy with us.\n'
            '${policyBits.join('\n')}\n'
            'We appreciate your trust and are happy to assist you anytime.\n'
            '$sender';
    }
  }

  static String _senderLine(WhatsAppTemplateData data) {
    final senderParts = <String>[
      if ((data.agentName ?? '').trim().isNotEmpty) data.agentName!.trim(),
      if ((data.agentMobile ?? '').trim().isNotEmpty) data.agentMobile!.trim(),
    ];
    return senderParts.isEmpty
        ? 'Regards,\nNinaivu Insurance Team'
        : 'Regards,\n${senderParts.join('\n')}';
  }
}
