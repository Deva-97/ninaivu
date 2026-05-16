import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/admin_user_list_controller.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class AgentListScreen extends GetView<AdminUserListController> {
  const AgentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminUserListScaffold(
      controller: controller,
      formRoute: AppRoutes.addEditAgent,
    );
  }
}

class CustomerListScreen extends GetView<AdminUserListController> {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminUserListScaffold(
      controller: controller,
      formRoute: AppRoutes.addEditCustomer,
    );
  }
}

class _AdminUserListScaffold extends StatelessWidget {
  const _AdminUserListScaffold({
    required this.controller,
    required this.formRoute,
  });

  final AdminUserListController controller;
  final String formRoute;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(formRoute);
          if (refreshed == true) {
            await controller.loadUsers();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Add ${controller.isAgentList ? 'Agent' : 'Customer'}'),
      ),
      body: Column(
        children: [
          ResponsiveContent(
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: TextField(
                controller: controller.searchController,
                onSubmitted: (_) => controller.loadUsers(),
                decoration: InputDecoration(
                  hintText: 'Search by name, mobile or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: controller.loadUsers,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingView(message: 'Loading users...');
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: 'Unable to load users',
                  message: error,
                  onRetry: controller.loadUsers,
                );
              }

              if (controller.users.isEmpty) {
                return AppEmptyState(
                  icon: controller.isAgentList
                      ? Icons.manage_accounts_outlined
                      : Icons.groups_outlined,
                  title: 'No ${controller.title.toLowerCase()} yet',
                  subtitle:
                      'Create your first ${controller.isAgentList ? 'agent' : 'customer'} to get started.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: ResponsiveContent(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      0,
                      responsive.pagePadding,
                      responsive.scaled(96, min: 84),
                    ),
                    itemCount: controller.users.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text(
                            [
                              if ((user.mobile ?? '').isNotEmpty) user.mobile!,
                              if ((user.email ?? '').isNotEmpty) user.email!,
                            ].join(' • '),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final refreshed = await Get.toNamed(
                                  formRoute,
                                  arguments: user,
                                );
                                if (refreshed == true) {
                                  await controller.loadUsers();
                                }
                              } else if (value == 'delete') {
                                final confirmed = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: const Text('Delete user'),
                                    content: Text('Soft-delete ${user.name}?'),
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
                                  await controller.deleteUser(user.id);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit status'),
                              ),
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
