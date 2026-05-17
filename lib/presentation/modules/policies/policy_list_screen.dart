import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/policy_list_controller.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class PolicyListScreen extends GetView<PolicyListController> {
  const PolicyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Policies')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(
            AppRoutes.policyForm,
            arguments: {'clientId': controller.clientId},
          );
          if (refreshed == true) {
            await controller.loadPolicies();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Policy'),
      ),
      body: Column(
        children: [
          if (controller.clientId == null)
            ResponsiveContent(
              child: Padding(
                padding: EdgeInsets.all(responsive.pagePadding),
                child: TextField(
                  controller: controller.searchController,
                  onSubmitted: (_) => controller.loadPolicies(),
                  decoration: InputDecoration(
                    hintText: 'Search by policy number, company or type',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: controller.loadPolicies,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingView(message: 'Loading policies...');
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: 'Unable to load policies',
                  message: error,
                  onRetry: controller.loadPolicies,
                );
              }

              if (controller.policies.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.description_outlined,
                  title: 'No policies yet',
                  subtitle: 'Create a policy to start tracking renewals.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadPolicies,
                child: ResponsiveContent(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      0,
                      responsive.pagePadding,
                      responsive.scaled(96, min: 84),
                    ),
                    itemCount: controller.policies.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final policy = controller.policies[index];
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            final refreshed = await Get.toNamed(
                              AppRoutes.policyDetails,
                              arguments: policy.id,
                            );
                            if (refreshed == true) {
                              await controller.loadPolicies();
                            }
                          },
                          title: Text(policy.policyNumber),
                          subtitle: Text(
                            '${policy.companyName} • ${policy.insuranceType}\n'
                            'Valid till ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.endDate))}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final refreshed = await Get.toNamed(
                                  AppRoutes.policyForm,
                                  arguments: policy,
                                );
                                if (refreshed == true) {
                                  await controller.loadPolicies();
                                }
                              } else if (value == 'delete') {
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
                                  await controller.deletePolicy(policy.id);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
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
