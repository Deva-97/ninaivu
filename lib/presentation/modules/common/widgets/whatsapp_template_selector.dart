import 'package:flutter/material.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showWhatsAppTemplateSelector({
  required BuildContext context,
  required String mobile,
  required WhatsAppTemplateData data,
}) async {
  final selectedTemplate = await showModalBottomSheet<WhatsAppTemplateType>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: WhatsAppTemplateBuilder.labels.entries
              .map(
                (entry) => ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: Text(entry.value),
                  onTap: () => Navigator.of(context).pop(entry.key),
                ),
              )
              .toList(),
        ),
      );
    },
  );
  if (selectedTemplate == null) {
    return;
  }

  final message = WhatsAppTemplateBuilder.build(
    template: selectedTemplate,
    data: data,
  );
  final digits = mobile.replaceAll(RegExp(r'[^0-9]'), '');
  final uri = Uri.parse('https://wa.me/91$digits?text=${Uri.encodeComponent(message)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
