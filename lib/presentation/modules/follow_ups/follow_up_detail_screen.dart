import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/localized_value_helper.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_detail_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/whatsapp_template_selector.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class FollowUpDetailScreen extends GetView<FollowUpDetailController> {
  const FollowUpDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationKeys.followUpDetails.tr),
        actions: [
          IconButton(
            onPressed: () async {
              final followUp = controller.followUp.value;
              if (followUp == null) {
                return;
              }
              final refreshed = await Get.toNamed(
                AppRoutes.followUpForm,
                arguments: followUp,
              );
              if (refreshed == true) {
                await controller.loadFollowUp();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return AppLoadingView(message: TranslationKeys.loadingFollowUp.tr);
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: TranslationKeys.unableToLoadFollowUp.tr,
            message: error,
            onRetry: controller.loadFollowUp,
          );
        }

        final followUp = controller.followUp.value;
        if (followUp == null) {
          return AppEmptyState(
            icon: Icons.assignment_late_outlined,
            title: TranslationKeys.followUpUnavailable.tr,
            subtitle: TranslationKeys.followUpNotFound.tr,
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
                        followUp.clientName ??
                            '${TranslationKeys.clientLabel.tr} ${followUp.clientId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: responsive.itemGap),
                      StatusBadge(
                        label: LocalizedValueHelper.followUpStatus(
                          followUp.status,
                        ),
                      ),
                      SizedBox(height: responsive.scaled(18, min: 14)),
                      _DetailRow(
                        label: TranslationKeys.type.tr,
                        value: LocalizedValueHelper.followUpType(followUp.type),
                      ),
                      _DetailRow(
                        label: TranslationKeys.when.tr,
                        value: dateFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            followUp.followUpDateTime,
                          ),
                        ),
                      ),
                      _DetailRow(
                        label: TranslationKeys.policyLabel.tr,
                        value:
                            followUp.policyNumber ??
                            followUp.policyId ??
                            TranslationKeys.notLinked.tr,
                      ),
                      _DetailRow(
                        label: TranslationKeys.customerMobile.tr,
                        value:
                            followUp.clientMobile ??
                            TranslationKeys.notAvailable.tr,
                      ),
                      _DetailRow(
                        label: TranslationKeys.remarks.tr,
                        value: followUp.remarks ?? TranslationKeys.noNotes.tr,
                      ),
                      _DetailRow(
                        label: TranslationKeys.syncStatus.tr,
                        value: followUp.syncStatus,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsive.itemGap),
              if ((followUp.clientMobile ?? '').isNotEmpty)
                Wrap(
                  spacing: responsive.scaled(12, min: 10),
                  runSpacing: responsive.scaled(12, min: 10),
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.callClient,
                      icon: const Icon(Icons.call_outlined),
                      label: Text(TranslationKeys.callCustomer.tr),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showWhatsAppTemplateSelector(
                        context: context,
                        mobile: followUp.clientMobile!,
                        data: WhatsAppTemplateData(
                          clientName: followUp.clientName,
                          mobile: followUp.clientMobile,
                          policyNumber: followUp.policyNumber,
                          followUpType: followUp.type,
                        ),
                      ),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(TranslationKeys.whatsapp.tr),
                    ),
                  ],
                ),
              SizedBox(height: responsive.sectionGap),
              if (followUp.status != 'Completed' &&
                  followUp.status != 'Cancelled')
                Column(
                  children: [
                    SizedBox(
                      height: responsive.compactButtonHeight,
                      child: AppButton(
                        label: TranslationKeys.markCompleted.tr,
                        onPressed: controller.markCompleted,
                        isLoading: controller.isUpdating.value,
                      ),
                    ),
                    SizedBox(height: responsive.scaled(10, min: 8)),
                    SizedBox(
                      height: responsive.compactButtonHeight,
                      child: OutlinedButton(
                        onPressed: () => _showRescheduleDialog(context),
                        child: Text(TranslationKeys.reschedule.tr),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: responsive.scaled(12, min: 10)),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text(TranslationKeys.deleteFollowUp.tr),
                      content: Text(TranslationKeys.softDeleteFollowUp.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text(TranslationKeys.cancel.tr),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(TranslationKeys.delete.tr),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await controller.deleteFollowUp();
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(TranslationKeys.deleteFollowUpButton.tr),
              ),
            ],
          ),
        );
      }),
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
      await controller.reschedule(picked.millisecondsSinceEpoch);
    }
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
