import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/policy_detail_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class PolicyDetailScreen extends GetView<PolicyDetailController> {
  const PolicyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rs. ');
    final dateFormat = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final policy = controller.policy.value;
              if (policy == null) {
                return;
              }
              final refreshed = await Get.toNamed(AppRoutes.policyForm, arguments: policy);
              if (refreshed == true) {
                await controller.loadPolicy();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingView(message: 'Loading policy...');
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: 'Unable to load policy',
            message: error,
            onRetry: controller.loadPolicy,
          );
        }

        final policy = controller.policy.value;
        if (policy == null) {
          return const AppEmptyState(
            icon: Icons.description_outlined,
            title: 'Policy unavailable',
            subtitle: 'This policy could not be found.',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.policyNumber,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Company', value: policy.companyName),
                    _DetailRow(label: 'Type', value: policy.insuranceType),
                    _DetailRow(label: 'Client ID', value: policy.clientId),
                    _DetailRow(
                      label: 'Premium',
                      value: currency.format(policy.premiumAmount),
                    ),
                    _DetailRow(
                      label: 'Start Date',
                      value: dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(policy.startDate),
                      ),
                    ),
                    _DetailRow(
                      label: 'End Date',
                      value: dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(policy.endDate),
                      ),
                    ),
                    _DetailRow(label: 'Status', value: policy.status),
                    _DetailRow(
                      label: 'Vehicle',
                      value: policy.vehicleNumber ?? policy.vehicleModel ?? 'Not applicable',
                    ),
                    _DetailRow(label: 'Notes', value: policy.notes ?? 'No notes'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete policy'),
                    content: Text('Soft-delete ${policy.policyNumber}?'),
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
                  await controller.deletePolicy();
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Policy'),
            ),
          ],
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
