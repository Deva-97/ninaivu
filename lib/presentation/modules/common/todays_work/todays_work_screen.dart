import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/presentation/controllers/todays_work_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/whatsapp_template_selector.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TodaysWorkScreen extends GetView<TodaysWorkController> {
  const TodaysWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.todaysWork.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return AppLoadingView(message: TranslationKeys.loadingTodaysWork.tr);
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: TranslationKeys.unableToLoadTodaysWork.tr,
            message: error,
            onRetry: controller.loadData,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: [
                DashboardHeroCard(
                  title: TranslationKeys.todaysPriority.tr,
                  subtitle: TranslationKeys.agentPrioritySubtitle.tr,
                  primaryValue:
                      controller.renewalsToday.length + controller.followUpsToday.length,
                  primaryLabel: TranslationKeys.todaysWork.tr,
                  primaryIcon: Icons.today_outlined,
                  highlights: [
                    DashboardHeroHighlight(
                      label: TranslationKeys.renewalsToday.tr,
                      value: controller.renewalsToday.length,
                      color: AppColors.warning,
                    ),
                    DashboardHeroHighlight(
                      label: TranslationKeys.followUpsToday.tr,
                      value: controller.followUpsToday.length,
                      color: AppColors.info,
                    ),
                    DashboardHeroHighlight(
                      label: TranslationKeys.missedFollowUps.tr,
                      value: controller.missedFollowUps.length,
                      color: AppColors.danger,
                    ),
                  ],
                ),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.renewalsToday.tr,
                  count: controller.renewalsToday.length,
                ),
                ...controller.renewalsToday.map((item) => _ReminderWorkCard(item: item)),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.upcomingRenewals.tr,
                  count: controller.upcomingRenewals.length,
                ),
                ...controller.upcomingRenewals.map(
                  (item) => _ReminderWorkCard(item: item),
                ),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.followUpsToday.tr,
                  count: controller.followUpsToday.length,
                ),
                ...controller.followUpsToday.map((item) => _FollowUpWorkCard(item: item)),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.missedFollowUps.tr,
                  count: controller.missedFollowUps.length,
                ),
                ...controller.missedFollowUps.map((item) => _FollowUpWorkCard(item: item)),
                SizedBox(height: responsive.sectionGap),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sync_problem_outlined),
                    title: Text(TranslationKeys.backupSyncPending.tr),
                    subtitle: Text(
                      '${controller.pendingSyncCount.value} ${TranslationKeys.itemsWaiting.tr}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          StatusBadge(label: count.toString()),
        ],
      ),
    );
  }
}

class _ReminderWorkCard extends GetView<TodaysWorkController> {
  const _ReminderWorkCard({required this.item});

  final Reminder item;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ReminderCard(
        reminder: item,
        subtitle:
            '${item.policyNumber ?? TranslationKeys.policyLabel.tr} - '
            '${item.companyName ?? TranslationKeys.insuranceLabel.tr}\n'
            '${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.reminderDateTime))}',
        onTap: () => Get.toNamed(
          AppRoutes.reminderDetails,
          arguments: item.id,
        ),
        actions: [
          if ((item.clientMobile ?? '').isNotEmpty)
            _actionButton(
              context: context,
              icon: Icons.call_outlined,
              label: TranslationKeys.call.tr,
              onPressed: () => launchUrl(Uri.parse('tel:${item.clientMobile}')),
            ),
          if ((item.clientMobile ?? '').isNotEmpty)
            _actionButton(
              context: context,
              icon: Icons.chat_outlined,
              label: TranslationKeys.whatsapp.tr,
              onPressed: () => showWhatsAppTemplateSelector(
                context: context,
                mobile: item.clientMobile!,
                data: WhatsAppTemplateData(
                  clientName: item.clientName,
                  mobile: item.clientMobile,
                  policyNumber: item.policyNumber,
                  companyName: item.companyName,
                ),
              ),
            ),
          OutlinedButton(
            onPressed: () => Get.toNamed(
              AppRoutes.reminderDetails,
              arguments: item.id,
            ),
            child: Text(TranslationKeys.viewDetails.tr),
          ),
          FilledButton(
            onPressed: () => controller.markReminderCompleted(item.id),
            child: Text(TranslationKeys.markCompleted.tr),
          ),
          FilledButton.tonal(
            onPressed: () => controller.markReminderRenewed(item.id),
            child: Text(TranslationKeys.markRenewed.tr),
          ),
        ],
      ),
    );
  }
}

class _FollowUpWorkCard extends GetView<TodaysWorkController> {
  const _FollowUpWorkCard({required this.item});

  final FollowUp item;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FollowUpCard(
        followUp: item,
        subtitle:
            '${item.type} - ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.followUpDateTime))}\n'
            '${item.policyNumber ?? TranslationKeys.noPolicyLinked.tr}',
        onTap: () => Get.toNamed(
          AppRoutes.followUpDetails,
          arguments: item.id,
        ),
        actions: [
          if ((item.clientMobile ?? '').isNotEmpty)
            _actionButton(
              context: context,
              icon: Icons.call_outlined,
              label: TranslationKeys.call.tr,
              onPressed: () => launchUrl(Uri.parse('tel:${item.clientMobile}')),
            ),
          if ((item.clientMobile ?? '').isNotEmpty)
            _actionButton(
              context: context,
              icon: Icons.chat_outlined,
              label: TranslationKeys.whatsapp.tr,
              onPressed: () => showWhatsAppTemplateSelector(
                context: context,
                mobile: item.clientMobile!,
                data: WhatsAppTemplateData(
                  clientName: item.clientName,
                  mobile: item.clientMobile,
                  policyNumber: item.policyNumber,
                  followUpType: item.type,
                ),
              ),
            ),
          OutlinedButton(
            onPressed: () => Get.toNamed(
              AppRoutes.followUpDetails,
              arguments: item.id,
            ),
            child: Text(TranslationKeys.viewDetails.tr),
          ),
          FilledButton(
            onPressed: () => controller.markFollowUpCompleted(item.id),
            child: Text(TranslationKeys.markCompleted.tr),
          ),
          FilledButton.tonal(
            onPressed: () => _showRescheduleDialog(context),
            child: Text(TranslationKeys.reschedule.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _showRescheduleDialog(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(TranslationKeys.tomorrow.tr),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 1))),
              ),
              ListTile(
                title: Text(TranslationKeys.after3Days.tr),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 3))),
              ),
              ListTile(
                title: Text(TranslationKeys.nextWeek.tr),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 7))),
              ),
              ListTile(
                title: Text(TranslationKeys.pickCustomDateTime.tr),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 2),
                  );
                  if (date == null || !context.mounted) {
                    return;
                  }
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time == null || !context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop(
                    DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      await controller.rescheduleFollowUp(
        followUpId: item.id,
        scheduledAt: picked.millisecondsSinceEpoch,
      );
    }
  }
}

Widget _actionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: Size(0, context.responsive.compactButtonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
