import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/reminder_detail_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/whatsapp_template_selector.dart';

class ReminderDetailScreen extends GetView<ReminderDetailController> {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Details')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingView(message: 'Loading reminder...');
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: 'Unable to load reminder',
            message: error,
            onRetry: controller.loadReminder,
          );
        }

        final reminder = controller.reminder.value;
        if (reminder == null) {
          return const AppEmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'Reminder unavailable',
            subtitle: 'This reminder could not be found.',
          );
        }

        return ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(responsive.scaled(18, min: 14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.clientName ?? 'Client ${reminder.clientId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: responsive.itemGap),
                      StatusBadge(label: _statusLabel(reminder.status)),
                      SizedBox(height: responsive.scaled(18, min: 14)),
                      _DetailRow(
                        label: 'Policy',
                        value: reminder.policyNumber ?? reminder.policyId,
                      ),
                      _DetailRow(
                        label: 'Company',
                        value: reminder.companyName ?? 'Not available',
                      ),
                      _DetailRow(
                        label: 'Reminder Type',
                        value: reminder.reminderType,
                      ),
                      _DetailRow(
                        label: 'Schedule',
                        value: dateFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            reminder.reminderDateTime,
                          ),
                        ),
                      ),
                      _DetailRow(
                        label: 'Notification ID',
                        value:
                            reminder.notificationId?.toString() ??
                            'Not scheduled',
                      ),
                      _DetailRow(
                        label: 'Sync Status',
                        value: reminder.syncStatus,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsive.sectionGap),
              if ((reminder.clientMobile ?? '').isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: responsive.itemGap),
                  child: Wrap(
                    spacing: responsive.scaled(12, min: 10),
                    children: [
                      OutlinedButton.icon(
                        onPressed: controller.callClient,
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Call'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showWhatsAppTemplateSelector(
                          context: context,
                          mobile: reminder.clientMobile!,
                          data: WhatsAppTemplateData(
                            clientName: reminder.clientName,
                            mobile: reminder.clientMobile,
                            policyNumber: reminder.policyNumber,
                            companyName: reminder.companyName,
                          ),
                        ),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('WhatsApp'),
                      ),
                    ],
                  ),
                ),
              if (reminder.status.toLowerCase() != 'completed' &&
                  reminder.status.toLowerCase() != 'cancelled')
                Column(
                  children: [
                    SizedBox(
                      height: responsive.compactButtonHeight,
                      child: AppButton(
                        label: 'Mark Completed',
                        onPressed: controller.markCompleted,
                        isLoading: controller.isUpdating.value,
                      ),
                    ),
                    SizedBox(height: responsive.scaled(10, min: 8)),
                    SizedBox(
                      height: responsive.compactButtonHeight,
                      child: OutlinedButton(
                        onPressed: controller.markRenewed,
                        child: const Text('Mark Renewed'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  String _statusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Pending';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.scaled(12, min: 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: responsive.detailLabelWidth, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
