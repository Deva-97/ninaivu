import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ClientListScreen extends GetView<ClientListController> {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            onPressed: () async {
              final format = await showExportFormatPicker(title: 'Export clients');
              if (format != null) {
                await controller.exportClients(format);
              }
            },
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export clients',
          ),
        ],
      ),
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
          ResponsiveContent(
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
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
                child: ResponsiveContent(
                  child: ListView.separated(
                    controller: controller.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      0,
                      responsive.pagePadding,
                      responsive.scaled(96, min: 84),
                    ),
                    itemCount:
                        controller.clients.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      if (index >= controller.clients.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

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
                          leading: ProfileAvatar(
                            name: client.name,
                            imagePath: client.profileImagePath,
                            radius: 22,
                          ),
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
                              PopupMenuItem(
                                value: 'policies',
                                child: Text('View policies'),
                              ),
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
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
