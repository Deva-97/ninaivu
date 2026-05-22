import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class FollowUpListScreen extends GetView<FollowUpListController> {
  const FollowUpListScreen({super.key});

  static final filters = <MapEntry<String, String>>[
    MapEntry('today', TranslationKeys.today.tr),
    MapEntry('upcoming', TranslationKeys.upcoming.tr),
    MapEntry('missed', TranslationKeys.missed.tr),
    MapEntry('completed', TranslationKeys.completed.tr),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return AppShellScaffold(
      currentTab: AppShellTab.followUps,
      dashboardRoute: AppRoutes.agentDashboard,
      title: TranslationKeys.followUps.tr,
      subtitle: TranslationKeys.followUpSubtitle.tr,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(AppRoutes.followUpForm);
          if (refreshed == true) {
            await controller.loadFollowUps();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(TranslationKeys.addFollowUp.tr),
      ),
      body: Column(
        children: [
          Obx(
            () => ResponsiveContent(
              child: AppFilterChips(
                items: filters,
                selectedKey: controller.selectedFilter.value,
                onSelected: (value) => controller.loadFollowUps(filter: value),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return AppLoadingView(message: TranslationKeys.loadingFollowUps.tr);
              }
              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: TranslationKeys.unableToLoadFollowUps.tr,
                  message: error,
                  onRetry: controller.loadFollowUps,
                );
              }
              if (controller.followUps.isEmpty) {
                return AppEmptyState(
                  icon: Icons.assignment_late_outlined,
                  title: TranslationKeys.noFollowUpsFound.tr,
                  subtitle: TranslationKeys.noFollowUpsSubtitle.tr,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadFollowUps,
                child: ResponsiveContent(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      responsive.scaled(8, min: 6),
                      responsive.pagePadding,
                      responsive.scaled(110, min: 96),
                    ),
                    itemCount: controller.followUps.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final followUp = controller.followUps[index];
                      return FollowUpCard(
                        followUp: followUp,
                        subtitle:
                            '${followUp.type} - ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(followUp.followUpDateTime))}\n'
                            '${followUp.policyNumber ?? TranslationKeys.noPolicyLinked.tr}',
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.followUpDetails,
                            arguments: followUp.id,
                          );
                          if (refreshed == true) {
                            await controller.loadFollowUps();
                          }
                        },
                        onMenuSelected: (value) async {
                          if (value == 'edit') {
                            final refreshed = await Get.toNamed(
                              AppRoutes.followUpForm,
                              arguments: followUp,
                            );
                            if (refreshed == true) {
                              await controller.loadFollowUps();
                            }
                          } else if (value == 'delete') {
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
                              await controller.deleteFollowUp(followUp.id);
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
