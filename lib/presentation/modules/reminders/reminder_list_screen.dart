import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/reminder_list_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class ReminderListScreen extends GetView<ReminderListController> {
  const ReminderListScreen({super.key});

  static const filters = <MapEntry<String, String>>[
    MapEntry('today', 'Today'),
    MapEntry('upcoming7days', 'Upcoming 7 days'),
    MapEntry('upcoming30days', 'Upcoming 30 days'),
    MapEntry('missed', 'Missed'),
    MapEntry('completed', 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Scaffold(
      appBar: AppBar(title: const Text('Renewal Reminders')),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: Obx(
              () {
                final selectedFilter = controller.selectedFilter.value;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    final isSelected = selectedFilter == filter.key;
                    return ChoiceChip(
                      label: Text(filter.value),
                      selected: isSelected,
                      onSelected: (_) => controller.loadReminders(filter: filter.key),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemCount: filters.length,
                );
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingView(message: 'Loading reminders...');
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: 'Unable to load reminders',
                  message: error,
                  onRetry: controller.loadReminders,
                );
              }

              if (controller.reminders.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No reminders found',
                  subtitle: 'Renewal reminders will appear here once policies are due.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadReminders,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: controller.reminders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final reminder = controller.reminders[index];
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.reminderDetails,
                            arguments: reminder.id,
                          );
                          if (refreshed == true) {
                            await controller.loadReminders();
                          }
                        },
                        title: Text(reminder.clientName ?? 'Client ${reminder.clientId}'),
                        subtitle: Text(
                          '${reminder.policyNumber ?? 'Policy'} • ${reminder.companyName ?? 'Insurance'}\n'
                          '${reminder.reminderType} • ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(reminder.reminderDateTime))}',
                        ),
                        isThreeLine: true,
                        trailing: StatusBadge(label: _statusLabel(reminder.status)),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
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
