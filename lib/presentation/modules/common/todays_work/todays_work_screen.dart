import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/presentation/controllers/todays_work_controller.dart';
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
                _SectionHeader(
                  title: TranslationKeys.renewalsToday.tr,
                  count: controller.renewalsToday.length,
                ),
                ...controller.renewalsToday.map(
                  (item) => _ReminderCard(item: item),
                ),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.upcomingRenewals.tr,
                  count: controller.upcomingRenewals.length,
                ),
                ...controller.upcomingRenewals.map(
                  (item) => _ReminderCard(item: item),
                ),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.followUpsToday.tr,
                  count: controller.followUpsToday.length,
                ),
                ...controller.followUpsToday.map(
                  (item) => _FollowUpCard(item: item),
                ),
                SizedBox(height: responsive.sectionGap),
                _SectionHeader(
                  title: TranslationKeys.missedFollowUps.tr,
                  count: controller.missedFollowUps.length,
                ),
                ...controller.missedFollowUps.map(
                  (item) => _FollowUpCard(item: item),
                ),
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

class _ReminderCard extends GetView<TodaysWorkController> {
  const _ReminderCard({required this.item});

  final Reminder item;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.clientName ?? 'Client ${item.clientId}'),
            const SizedBox(height: 6),
            Text(
              '${item.policyNumber ?? 'Policy'} - ${item.companyName ?? 'Insurance'}\n'
              '${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.reminderDateTime))}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((item.clientMobile ?? '').isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${item.clientMobile}')),
                    icon: const Icon(Icons.call_outlined),
                    label: Text(TranslationKeys.call.tr),
                  ),
                if ((item.clientMobile ?? '').isNotEmpty)
                  OutlinedButton.icon(
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
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(TranslationKeys.whatsapp.tr),
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
          ],
        ),
      ),
    );
  }
}

class _FollowUpCard extends GetView<TodaysWorkController> {
  const _FollowUpCard({required this.item});

  final FollowUp item;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.clientName ?? 'Client ${item.clientId}'),
            const SizedBox(height: 6),
            Text(
              '${item.type} - ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.followUpDateTime))}\n'
              '${item.policyNumber ?? TranslationKeys.noPolicyLinked.tr}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((item.clientMobile ?? '').isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${item.clientMobile}')),
                    icon: const Icon(Icons.call_outlined),
                    label: Text(TranslationKeys.call.tr),
                  ),
                if ((item.clientMobile ?? '').isNotEmpty)
                  OutlinedButton.icon(
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
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(TranslationKeys.whatsapp.tr),
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
          ],
        ),
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
