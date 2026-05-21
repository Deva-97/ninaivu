import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/presentation/modules/common/widgets/whatsapp_template_selector.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_detail_controller.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class FollowUpDetailScreen extends GetView<FollowUpDetailController> {
  const FollowUpDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow-up Details'),
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
          return const AppLoadingView(message: 'Loading follow-up...');
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: 'Unable to load follow-up',
            message: error,
            onRetry: controller.loadFollowUp,
          );
        }

        final followUp = controller.followUp.value;
        if (followUp == null) {
          return const AppEmptyState(
            icon: Icons.assignment_late_outlined,
            title: 'Follow-up unavailable',
            subtitle: 'This follow-up could not be found.',
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
                        followUp.clientName ?? 'Client ${followUp.clientId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: responsive.itemGap),
                      StatusBadge(label: followUp.status),
                      SizedBox(height: responsive.scaled(18, min: 14)),
                      _DetailRow(label: 'Type', value: followUp.type),
                      _DetailRow(
                        label: 'When',
                        value: dateFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            followUp.followUpDateTime,
                          ),
                        ),
                      ),
                      _DetailRow(
                        label: 'Policy',
                        value:
                            followUp.policyNumber ??
                            followUp.policyId ??
                            'Not linked',
                      ),
                      _DetailRow(
                        label: 'Customer Mobile',
                        value: followUp.clientMobile ?? 'Not available',
                      ),
                      _DetailRow(
                        label: 'Remarks',
                        value: followUp.remarks ?? 'No remarks',
                      ),
                      _DetailRow(label: 'Sync Status', value: followUp.syncStatus),
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
                      label: const Text('Call Customer'),
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
                      label: const Text('WhatsApp'),
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
                        label: 'Mark Completed',
                        onPressed: controller.markCompleted,
                        isLoading: controller.isUpdating.value,
                      ),
                    ),
                    SizedBox(height: responsive.scaled(10, min: 8)),
                    SizedBox(
                      height: responsive.compactButtonHeight,
                      child: OutlinedButton(
                        onPressed: () => _showRescheduleDialog(context),
                        child: const Text('Reschedule'),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: responsive.scaled(12, min: 10)),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Delete follow-up'),
                      content: const Text('Soft-delete this follow-up?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await controller.deleteFollowUp();
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Follow-up'),
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
                title: const Text('Tomorrow'),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 1))),
              ),
              ListTile(
                title: const Text('After 3 days'),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 3))),
              ),
              ListTile(
                title: const Text('Next week'),
                onTap: () =>
                    Navigator.of(context).pop(now.add(const Duration(days: 7))),
              ),
              ListTile(
                title: const Text('Pick custom date/time'),
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
