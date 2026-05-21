import 'package:flutter/material.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';

/// Opens a bottom sheet that lets the user choose a prebuilt WhatsApp message
/// before launching chat with the selected client.
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

  // Message creation is centralized in the template builder so screens only
  // need to pass domain data and do not duplicate string composition.
  final message = WhatsAppTemplateBuilder.build(
    template: selectedTemplate,
    data: data,
  );
  await CommunicationService().openWhatsAppChat(mobile, message: message);
}
