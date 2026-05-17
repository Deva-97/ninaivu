import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_list_controller.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class FollowUpListScreen extends GetView<FollowUpListController> {
  const FollowUpListScreen({super.key});

  static const filters = <MapEntry<String, String>>[
    MapEntry('today', 'Today'),
    MapEntry('upcoming', 'Upcoming'),
    MapEntry('missed', 'Missed'),
    MapEntry('completed', 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-ups')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(AppRoutes.followUpForm);
          if (refreshed == true) {
            await controller.loadFollowUps();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Follow-up'),
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
                      label: Text(filter.value),
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
                return const AppLoadingView(message: 'Loading follow-ups...');
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: 'Unable to load follow-ups',
                  message: error,
                  onRetry: controller.loadFollowUps,
                );
              }

              if (controller.followUps.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.assignment_late_outlined,
                  title: 'No follow-ups found',
                  subtitle: 'Create a follow-up to track the next customer action.',
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
                            '${followUp.type} • ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(followUp.followUpDateTime))}\n'
                            '${followUp.policyNumber ?? 'No policy linked'}',
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
                                  await controller.deleteFollowUp(followUp.id);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
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
