import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/follow_up_detail_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class FollowUpDetailScreen extends GetView<FollowUpDetailController> {
  const FollowUpDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
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
                      followUp.clientName ?? 'Client ${followUp.clientId}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    StatusBadge(label: followUp.status),
                    const SizedBox(height: 18),
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
                      value: followUp.policyNumber ?? followUp.policyId ?? 'Not linked',
                    ),
                    _DetailRow(
                      label: 'Customer Mobile',
                      value: followUp.clientMobile ?? 'Not available',
                    ),
                    _DetailRow(
                      label: 'Remarks',
                      value: followUp.remarks ?? 'No remarks',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if ((followUp.clientMobile ?? '').isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openUri('tel:${followUp.clientMobile}'),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call Customer'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openUri(
                      'https://wa.me/91${followUp.clientMobile!.replaceAll(RegExp(r'[^0-9]'), '')}',
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            if (followUp.status != 'Completed' && followUp.status != 'Cancelled')
              SizedBox(
                height: 50,
                child: AppButton(
                  label: 'Mark Completed',
                  onPressed: controller.markCompleted,
                  isLoading: controller.isUpdating.value,
                ),
              ),
            const SizedBox(height: 12),
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
        );
      }),
    );
  }

  Future<void> _openUri(String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Unable to open', 'The requested app could not be opened.');
    }
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
          SizedBox(width: 130, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
