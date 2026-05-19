import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/models/export_format.dart';

Future<ExportFormat?> showExportFormatPicker({
  required String title,
}) {
  return Get.bottomSheet<ExportFormat>(
    SafeArea(
      child: Material(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Get.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to export this data.',
                style: Get.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...ExportFormat.values.map(
                (format) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFor(format)),
                  title: Text(format.label),
                  subtitle: Text(format.description),
                  onTap: () => Get.back(result: format),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

IconData _iconFor(ExportFormat format) {
  return switch (format) {
    ExportFormat.csv => Icons.table_chart_outlined,
    ExportFormat.pdf => Icons.picture_as_pdf_outlined,
    ExportFormat.doc => Icons.description_outlined,
    ExportFormat.txt => Icons.notes_outlined,
  };
}
