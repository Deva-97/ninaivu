import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/agent_dashboard_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/dashboard_widgets.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/modules/common/widgets/profile_image_actions.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class AgentDashboardScreen extends GetView<AgentDashboardController> {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return AppShellScaffold(
      currentTab: AppShellTab.dashboard,
      dashboardRoute: AppRoutes.agentDashboard,
      title: TranslationKeys.agentDashboard.tr,
      subtitle: TranslationKeys.yourPortfolio.tr,
      actions: [
        AppIconButton(
          tooltip: TranslationKeys.search.tr,
          icon: Icons.search_rounded,
          onPressed: () => Get.toNamed(AppRoutes.globalSearch),
        ),
        Obx(
          () => AppIconButton(
            tooltip: controller.isSyncing.value
                ? TranslationKeys.syncing.tr
                : TranslationKeys.syncNow.tr,
            icon: controller.isSyncing.value ? Icons.sync : Icons.sync_rounded,
            onPressed: controller.isSyncing.value ? null : controller.syncNow,
          ),
        ),
      ],
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
              constraints: BoxConstraints(maxWidth: responsive.dashboardContentMaxWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  0,
                  responsive.pagePadding,
                  responsive.scaled(110, min: 96),
                ),
                children: [
                  Obx(() {
                    final user = controller.currentUser.value;
                    if (user == null) {
                      return const SizedBox.shrink();
                    }
                    return ProfileAvatarBlock(
                      name: user.name,
                      subtitle: '${controller.backupStatusLabel.value} - ${controller.lastSyncLabel.value}',
                      statusLabel: TranslationKeys.roleAgent.tr,
                      imagePath: user.profileImagePath,
                      imageData: user.profileImageData,
                      onTap: () => showProfileImageViewer(
                        context: context,
                        name: user.name,
                        imagePath: user.profileImagePath,
                        imageData: user.profileImageData,
                      ),
                    );
                  }),
                  SizedBox(height: responsive.sectionGap),
                  SectionTitle(
                    title: TranslationKeys.yourPortfolio.tr,
                    subtitle: TranslationKeys.portfolioSummary.tr,
                  ),
                  SizedBox(height: responsive.itemGap),
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
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  SectionTitle(title: TranslationKeys.quickActions.tr),
                  SizedBox(height: responsive.itemGap),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
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
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  SectionTitle(title: TranslationKeys.upcomingDates.tr),
                  SizedBox(height: responsive.itemGap),
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
