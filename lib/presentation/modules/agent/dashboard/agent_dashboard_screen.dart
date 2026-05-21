import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/agent_dashboard_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/dashboard_widgets.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/modules/common/widgets/profile_image_actions.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class AgentDashboardScreen extends GetView<AgentDashboardController> {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationKeys.agentDashboard.tr),
        actions: [
          IconButton(
            tooltip: TranslationKeys.search.tr,
            onPressed: () => Get.toNamed(AppRoutes.globalSearch),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: TranslationKeys.settings.tr,
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          Obx(
            () => IconButton(
              tooltip: controller.isSyncing.value
                  ? TranslationKeys.syncing.tr
                  : TranslationKeys.syncNow.tr,
              onPressed: controller.isSyncing.value ? null : controller.syncNow,
              icon: controller.isSyncing.value
                  ? SizedBox(
                      width: responsive.scaled(18, min: 16),
                      height: responsive.scaled(18, min: 16),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
            ),
          ),
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfileAvatar(
                name: user.name,
                imagePath: user.profileImagePath,
                imageData: user.profileImageData,
                radius: 18,
                onTap: () => showProfileImageViewer(
                  context: context,
                  name: user.name,
                  imagePath: user.profileImagePath,
                  imageData: user.profileImageData,
                ),
              ),
            );
          }),
          SizedBox(width: responsive.scaled(4, min: 2)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return AppLoadingView(message: TranslationKeys.loadingDashboard.tr);
        }

        final error = controller.errorMessage.value;
        if (error != null && controller.stats.value == null) {
          return AppErrorView(
            title: TranslationKeys.unableToLoadDashboard.tr,
            message: error,
            onRetry: controller.loadDashboard,
          );
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return AppEmptyState(
            icon: Icons.dashboard_outlined,
            title: TranslationKeys.dashboardUnavailable.tr,
            subtitle: TranslationKeys.dashboardUnavailableSubtitle.tr,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: responsive.dashboardContentMaxWidth,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  responsive.pagePadding,
                  responsive.pagePadding,
                  responsive.sectionGap,
                ),
                children: [
                  Text(
                    TranslationKeys.yourPortfolio.tr,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: responsive.scaled(6, min: 4)),
                  Text(
                    TranslationKeys.portfolioSummary.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: responsive.scaled(4, min: 4)),
                  Obx(
                    () => Text(
                      '${controller.backupStatusLabel.value} - ${controller.lastSyncLabel.value}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(height: responsive.scaled(18, min: 14)),
                  GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: responsive.dashboardGridCount,
                      crossAxisSpacing: responsive.metricGridSpacing,
                      mainAxisSpacing: responsive.metricGridSpacing,
                      mainAxisExtent: responsive.dashboardMetricHeight,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardMetricCard(
                        title: TranslationKeys.myClients.tr,
                        value: stats.myClients,
                        icon: Icons.people_outline_rounded,
                        color: Colors.indigo,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.myPolicies.tr,
                        value: stats.myPolicies,
                        icon: Icons.description_outlined,
                        color: Colors.deepPurple,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.renewalsToday.tr,
                        value: stats.renewalsToday,
                        icon: Icons.today_outlined,
                        color: Colors.orange,
                        badgeLabel: TranslationKeys.pending.tr,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.upcoming7Days.tr,
                        value: stats.upcoming7Days,
                        icon: Icons.date_range_outlined,
                        color: Colors.cyan,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.upcoming30Days.tr,
                        value: stats.upcoming30Days,
                        icon: Icons.event_repeat_outlined,
                        color: Colors.teal,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.followUpsToday.tr,
                        value: stats.followUpsToday,
                        icon: Icons.call_outlined,
                        color: Colors.amber,
                        badgeLabel: TranslationKeys.pending.tr,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.missedFollowUps.tr,
                        value: stats.missedFollowUps,
                        icon: Icons.history_toggle_off_rounded,
                        color: Colors.red,
                        badgeLabel: TranslationKeys.missed.tr,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  Text(
                    TranslationKeys.quickActions.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: responsive.scaled(12, min: 10)),
                  Wrap(
                    spacing: responsive.scaled(12, min: 10),
                    runSpacing: responsive.scaled(12, min: 10),
                    children: [
                      DashboardQuickAction(
                        label: TranslationKeys.todaysWork.tr,
                        icon: Icons.today_outlined,
                        color: Colors.orange,
                        onTap: () => Get.toNamed(AppRoutes.todaysWork),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.exportClients.tr,
                        icon: Icons.file_download_outlined,
                        color: Colors.blueGrey,
                        onTap: () async {
                          final format = await showExportFormatPicker(
                            title: TranslationKeys.exportClients.tr,
                          );
                          if (format != null) {
                            await controller.exportClients(format);
                          }
                        },
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.exportPolicies.tr,
                        icon: Icons.table_view_outlined,
                        color: Colors.brown,
                        onTap: () async {
                          final format = await showExportFormatPicker(
                            title: TranslationKeys.exportPolicies.tr,
                          );
                          if (format != null) {
                            await controller.exportPolicies(format);
                          }
                        },
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addClient.tr,
                        icon: Icons.person_add_alt_1_outlined,
                        color: Colors.indigo,
                        onTap: () => Get.toNamed(AppRoutes.clientForm),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addPolicy.tr,
                        icon: Icons.note_add_outlined,
                        color: Colors.deepPurple,
                        onTap: () => Get.toNamed(AppRoutes.policyForm),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addFollowUp.tr,
                        icon: Icons.add_alert_outlined,
                        color: Colors.orange,
                        onTap: () => Get.toNamed(AppRoutes.followUpForm),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.viewRenewals.tr,
                        icon: Icons.notifications_active_outlined,
                        color: Colors.teal,
                        onTap: () => Get.toNamed(
                          AppRoutes.reminders,
                          arguments: {'filter': 'pending'},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  Text(
                    TranslationKeys.upcomingDates.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: responsive.scaled(12, min: 10)),
                  Obx(() {
                    if (controller.upcomingEvents.isEmpty) {
                      return Text(TranslationKeys.noUpcomingDates.tr);
                    }
                    return Column(
                      children: controller.upcomingEvents
                          .map(
                            (event) => Card(
                              child: ListTile(
                                title: Text(event.clientName),
                                subtitle: Text(
                                  '${event.label} - ${DateFormat('dd MMM').format(DateTime.fromMillisecondsSinceEpoch(event.eventDateMs))}',
                                ),
                                trailing: Text(event.mobile),
                                onTap: () => Get.toNamed(
                                  AppRoutes.clientDetails,
                                  arguments: event.clientId,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
