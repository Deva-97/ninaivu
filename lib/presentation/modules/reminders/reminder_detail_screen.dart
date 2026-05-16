import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/reminder_detail_controller.dart';

class ReminderDetailScreen extends GetView<ReminderDetailController> {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.clientName ?? 'Client ${reminder.clientId}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    StatusBadge(label: _statusLabel(reminder.status)),
                    const SizedBox(height: 18),
                    _DetailRow(label: 'Policy', value: reminder.policyNumber ?? reminder.policyId),
                    _DetailRow(label: 'Company', value: reminder.companyName ?? 'Not available'),
                    _DetailRow(label: 'Reminder Type', value: reminder.reminderType),
                    _DetailRow(
                      label: 'Schedule',
                      value: dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(reminder.reminderDateTime),
                      ),
                    ),
                    _DetailRow(
                      label: 'Notification ID',
                      value: reminder.notificationId?.toString() ?? 'Not scheduled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (reminder.status.toLowerCase() != 'completed' &&
                reminder.status.toLowerCase() != 'cancelled')
              SizedBox(
                height: 50,
                child: AppButton(
                  label: 'Mark Completed',
                  onPressed: controller.markCompleted,
                  isLoading: controller.isUpdating.value,
                ),
              ),
          ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
