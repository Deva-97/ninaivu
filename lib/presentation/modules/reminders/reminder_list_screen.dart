import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/reminder_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ReminderListScreen extends GetView<ReminderListController> {
  const ReminderListScreen({super.key});

  static final filters = <MapEntry<String, String>>[
    MapEntry('pending', TranslationKeys.allUpcoming.tr),
    MapEntry('today', TranslationKeys.today.tr),
    MapEntry('upcoming7days', TranslationKeys.upcoming7Days.tr),
    MapEntry('upcoming30days', TranslationKeys.upcoming30Days.tr),
    MapEntry('missed', TranslationKeys.missed.tr),
    MapEntry('completed', TranslationKeys.completed.tr),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.renewalReminders.tr)),
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
                return AppLoadingView(message: TranslationKeys.loadingReminders.tr);
              }
              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: TranslationKeys.unableToLoadReminders.tr,
                  message: error,
                  onRetry: controller.loadReminders,
                );
              }
              if (controller.reminders.isEmpty) {
                return AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: TranslationKeys.noRemindersFound.tr,
                  subtitle: TranslationKeys.noRemindersSubtitle.tr,
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
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final reminder = controller.reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        subtitle:
                            '${reminder.policyNumber ?? TranslationKeys.policyLabel.tr} - '
                            '${reminder.companyName ?? TranslationKeys.insuranceLabel.tr}\n'
                            '${reminder.reminderType} - '
                            '${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(reminder.reminderDateTime))}',
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
