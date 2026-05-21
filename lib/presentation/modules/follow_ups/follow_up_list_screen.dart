import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_list_controller.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class FollowUpListScreen extends GetView<FollowUpListController> {
  const FollowUpListScreen({super.key});

  static const filters = <MapEntry<String, String>>[
    MapEntry('today', TranslationKeys.today),
    MapEntry('upcoming', TranslationKeys.upcoming),
    MapEntry('missed', TranslationKeys.missed),
    MapEntry('completed', TranslationKeys.completed),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.followUps.tr)),
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
          SizedBox(
            height: responsive.chipBarHeight,
            child: Obx(() {
              final selectedFilter = controller.selectedFilter.value;
              return ResponsiveContent(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                    vertical: responsive.scaled(10, min: 8),
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: responsive.scaled(8, min: 6)),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    return ChoiceChip(
                      label: Text(filter.value.tr),
                      selected: selectedFilter == filter.key,
                      onSelected: (_) => controller.loadFollowUps(filter: filter.key),
                    );
                  },
                ),
              );
            }),
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
                      responsive.scaled(96, min: 84),
                    ),
                    itemCount: controller.followUps.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      final followUp = controller.followUps[index];
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            final refreshed = await Get.toNamed(
                              AppRoutes.followUpDetails,
                              arguments: followUp.id,
                            );
                            if (refreshed == true) {
                              await controller.loadFollowUps();
                            }
                          },
                          title: Text(
                            followUp.clientName ?? 'Client ${followUp.clientId}',
                          ),
                          subtitle: Text(
                            '${followUp.type} - ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(followUp.followUpDateTime))}\n'
                            '${followUp.policyNumber ?? TranslationKeys.noPolicyLinked.tr}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
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
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(TranslationKeys.edit.tr),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(TranslationKeys.delete.tr),
                              ),
                            ],
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.scaled(8, min: 6),
                              ),
                              child: StatusBadge(label: followUp.status),
                            ),
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
