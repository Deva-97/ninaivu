import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/client_list_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class ClientListScreen extends GetView<ClientListController> {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(AppRoutes.clientForm);
          if (refreshed == true) {
            await controller.loadClients();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or mobile',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: controller.loadClients,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingView(message: 'Loading clients...');
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: 'Unable to load clients',
                  message: error,
                  onRetry: controller.loadClients,
                );
              }

              if (controller.clients.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No clients yet',
                  subtitle: 'Add your first client to start tracking policies.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadClients,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: controller.clients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final client = controller.clients[index];
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.clientDetails,
                            arguments: client.id,
                          );
                          if (refreshed == true) {
                            await controller.loadClients();
                          }
                        },
                        title: Text(client.name),
                        subtitle: Text(
                          '${client.mobile} • ${client.areaCity ?? 'Area not set'}\nPolicies: ${client.policyCount}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            try {
                              if (value == 'call') {
                                await controller.callClient(client.mobile);
                              } else if (value == 'whatsapp') {
                                await controller.whatsappClient(client.mobile);
                              } else if (value == 'policies') {
                                await Get.toNamed(
                                  AppRoutes.policies,
                                  arguments: {'clientId': client.id},
                                );
                              } else if (value == 'edit') {
                                final refreshed = await Get.toNamed(
                                  AppRoutes.clientForm,
                                  arguments: client,
                                );
                                if (refreshed == true) {
                                  await controller.loadClients();
                                }
                              } else if (value == 'delete') {
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
                                  await controller.deleteClient(client.id);
                                }
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Action failed',
                                e.toString().replaceFirst('Exception: ', ''),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'call', child: Text('Call')),
                            PopupMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                            PopupMenuItem(value: 'policies', child: Text('View policies')),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
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
}
