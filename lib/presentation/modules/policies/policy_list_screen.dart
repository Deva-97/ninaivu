import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/policy_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class PolicyListScreen extends GetView<PolicyListController> {
  const PolicyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return AppShellScaffold(
      currentTab: AppShellTab.policies,
      dashboardRoute: AppRoutes.agentDashboard,
      title: TranslationKeys.policies.tr,
      subtitle: controller.clientId == null
          ? 'Track active policies and renewals'
          : 'Policies linked to this client',
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
        label: Text(TranslationKeys.addPolicy.tr),
      ),
      actions: [
        AppIconButton(
          tooltip: TranslationKeys.exportPolicies.tr,
          icon: Icons.ios_share_outlined,
          onPressed: () async {
            final format = await showExportFormatPicker(
              title: TranslationKeys.exportPolicies.tr,
            );
            if (format != null) {
              await controller.exportPolicies(format);
            }
          },
        ),
      ],
      body: Column(
        children: [
          if (controller.clientId == null)
            ResponsiveContent(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
                child: AppSearchField(
                  controller: controller.searchController,
                  hintText: 'Search by policy number, company or type',
                  onSubmitted: (_) => controller.loadPolicies(),
                  onRefresh: controller.loadPolicies,
                ),
              ),
            ),
          if (controller.clientId == null) SizedBox(height: responsive.itemGap),
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
                    controller: controller.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      0,
                      responsive.pagePadding,
                      responsive.scaled(110, min: 96),
                    ),
                    itemCount: controller.policies.length + (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, _) => SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      if (index >= controller.policies.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final policy = controller.policies[index];
                      return PolicyCard(
                        policy: policy,
                        subtitle:
                            '${policy.companyName} • ${policy.insuranceType}\nValid till ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.endDate))}',
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.policyDetails,
                            arguments: policy.id,
                          );
                          if (refreshed == true) {
                            await controller.loadPolicies();
                          }
                        },
                        onMenuSelected: (value) async {
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
                              await controller.deletePolicy(policy.id);
                            }
                          }
                        },
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
