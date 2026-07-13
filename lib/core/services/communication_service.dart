import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  static final RegExp _indianMobilePattern = RegExp(
    r'^(?:\+91|91)?[6-9]\d{9}$',
  );

  bool isValidIndianMobile(String? value) {
    if (value == null) {
      return false;
    }
    final digits = normalizeMobile(value);
    return _indianMobilePattern.hasMatch(digits);
  }

  String normalizeMobile(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return digits;
    }
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    return digits;
  }

  Future<void> openDialer(String? mobile) async {
    if (!isValidIndianMobile(mobile)) {
      throw Exception(TranslationKeys.invalidMobile.tr);
    }

    final uri = Uri.parse('tel:${normalizeMobile(mobile!)}');
    if (!await launchUrl(uri)) {
      throw Exception(TranslationKeys.unableToOpenDialer.tr);
    }
  }

  Future<void> openWhatsAppChat(String? mobile, {String? message}) async {
    if (!isValidIndianMobile(mobile)) {
      throw Exception(TranslationKeys.invalidMobile.tr);
    }

    final number = normalizeMobile(mobile!);
    final textQuery = message == null || message.trim().isEmpty
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse('https://wa.me/91$number$textQuery');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception(TranslationKeys.unableToOpenWhatsApp.tr);
    }
  }

  Future<void> openWhatsAppTemplate({
    required String? mobile,
    required WhatsAppTemplateType template,
    required WhatsAppTemplateData data,
  }) {
    final message = WhatsAppTemplateBuilder.build(
      template: template,
      data: data,
    );
    return openWhatsAppChat(mobile, message: message);
  }
}
