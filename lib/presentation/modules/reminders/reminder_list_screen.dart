import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/reminder_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ReminderListScreen extends GetView<ReminderListController> {
  const ReminderListScreen({super.key});

  static const filters = <MapEntry<String, String>>[
    MapEntry('pending', 'All upcoming'),
    MapEntry('today', 'Today'),
    MapEntry('upcoming7days', 'Upcoming 7 days'),
    MapEntry('upcoming30days', 'Upcoming 30 days'),
    MapEntry('missed', 'Missed'),
    MapEntry('completed', 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Renewal Reminders')),
      body: Column(
        children: [
          Obx(
            () => ResponsiveContent(
              child: AppFilterChips(
                items: filters,
                selectedKey: controller.selectedFilter.value,
                onSelected: (value) => controller.loadReminders(filter: value),
              ),
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
                child: ResponsiveContent(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      responsive.scaled(8, min: 6),
                      responsive.pagePadding,
                      responsive.pagePadding,
                    ),
                    itemCount: controller.reminders.length,
                    separatorBuilder: (_, _) => SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final reminder = controller.reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        subtitle:
                            '${reminder.policyNumber ?? 'Policy'} • ${reminder.companyName ?? 'Insurance'}\n${reminder.reminderType} • ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(reminder.reminderDateTime))}',
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.reminderDetails,
                            arguments: reminder.id,
                          );
                          if (refreshed == true) {
                            await controller.loadReminders();
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
