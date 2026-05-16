import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/client_detail_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class ClientDetailScreen extends GetView<ClientDetailController> {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final client = controller.client.value;
              if (client == null) {
                return;
              }
              final refreshed = await Get.toNamed(AppRoutes.clientForm, arguments: client);
              if (refreshed == true) {
                await controller.loadClient();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingView(message: 'Loading client...');
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: 'Unable to load client',
            message: error,
            onRetry: controller.loadClient,
          );
        }

        final client = controller.client.value;
        if (client == null) {
          return const AppEmptyState(
            icon: Icons.person_off_outlined,
            title: 'Client unavailable',
            subtitle: 'This client could not be found.',
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
                      client.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Mobile', value: client.mobile),
                    _DetailRow(
                      label: 'Alternate',
                      value: client.alternateMobile ?? 'Not provided',
                    ),
                    _DetailRow(label: 'Email', value: client.email ?? 'Not provided'),
                    _DetailRow(label: 'Area / City', value: client.areaCity ?? 'Not set'),
                    _DetailRow(label: 'Address', value: client.address ?? 'Not provided'),
                    _DetailRow(label: 'Notes', value: client.notes ?? 'No notes'),
                    _DetailRow(
                      label: 'Policy Count',
                      value: client.policyCount.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => controller.callClient().catchError(_showError),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
                OutlinedButton.icon(
                  onPressed: () => controller.whatsappClient().catchError(_showError),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.policies,
                    arguments: {'clientId': client.id},
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Policies'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.policyForm,
                    arguments: {'clientId': client.id},
                  ),
                  icon: const Icon(Icons.add_card_outlined),
                  label: const Text('Add Policy'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete client'),
                    content: Text('Soft-delete ${client.name}?'),
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
                  await controller.deleteClient();
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Client'),
            ),
          ],
        );
      }),
    );
  }

  void _showError(Object error) {
    Get.snackbar('Action failed', error.toString().replaceFirst('Exception: ', ''));
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
