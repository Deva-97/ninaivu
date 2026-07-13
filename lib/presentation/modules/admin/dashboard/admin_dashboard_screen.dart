import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/admin_dashboard_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/dashboard_widgets.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/modules/common/widgets/profile_image_actions.dart';
import 'package:ninaivu/presentation/modules/policies/widgets/add_policy_method_sheet.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return AppShellScaffold(
      currentTab: AppShellTab.dashboard,
      dashboardRoute: AppRoutes.adminDashboard,
      title: TranslationKeys.adminDashboard.tr,
      subtitle: TranslationKeys.businessOverview.tr,
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
              constraints: BoxConstraints(
                maxWidth: responsive.dashboardContentMaxWidth,
              ),
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
                      subtitle:
                          '${controller.backupStatusLabel.value} - ${controller.lastSyncLabel.value}',
                      statusLabel: TranslationKeys.roleAdmin.tr,
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
                  DashboardHeroCard(
                    title: TranslationKeys.todaysPriority.tr,
                    subtitle: TranslationKeys.adminPrioritySubtitle.tr,
                    primaryValue: stats.renewalsToday,
                    primaryLabel: TranslationKeys.renewalsToday.tr,
                    primaryIcon: Icons.today_outlined,
                    highlights: [
                      DashboardHeroHighlight(
                        label: TranslationKeys.expiredPolicies.tr,
                        value: stats.expiredPolicies,
                        color: AppColors.danger,
                      ),
                      DashboardHeroHighlight(
                        label: TranslationKeys.pendingFollowUps.tr,
                        value: stats.pendingFollowUps,
                        color: AppColors.warning,
                      ),
                      DashboardHeroHighlight(
                        label: TranslationKeys.missedFollowUps.tr,
                        value: stats.missedFollowUps,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  SectionTitle(
                    title: TranslationKeys.businessHealth.tr,
                    subtitle: TranslationKeys.liveSqliteCounts.tr,
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
                        title: TranslationKeys.totalAgents.tr,
                        value: stats.totalAgents,
                        icon: Icons.support_agent_rounded,
                        color: AppColors.actionSecondary,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.totalCustomers.tr,
                        value: stats.totalCustomers,
                        icon: Icons.groups_2_outlined,
                        color: AppColors.info,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.totalClients.tr,
                        value: stats.totalClients,
                        icon: Icons.people_outline_rounded,
                        color: AppColors.primary,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.totalPolicies.tr,
                        value: stats.totalPolicies,
                        icon: Icons.description_outlined,
                        color: AppColors.heroBlue,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.renewalsToday.tr,
                        value: stats.renewalsToday,
                        icon: Icons.today_outlined,
                        color: AppColors.warning,
                        badgeLabel: TranslationKeys.pending.tr,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.upcoming7Days.tr,
                        value: stats.upcoming7Days,
                        icon: Icons.upcoming_outlined,
                        color: AppColors.info,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.expiredPolicies.tr,
                        value: stats.expiredPolicies,
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.danger,
                        badgeLabel: TranslationKeys.missed.tr,
                      ),
                      DashboardMetricCard(
                        title: TranslationKeys.pendingFollowUps.tr,
                        value: stats.pendingFollowUps,
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.priority,
                        badgeLabel: TranslationKeys.pending.tr,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  DashboardActionGroup(
                    title: TranslationKeys.primaryActions.tr,
                    subtitle: TranslationKeys.quickToolsSubtitle.tr,
                    children: [
                      DashboardQuickAction(
                        label: TranslationKeys.todaysWork.tr,
                        icon: Icons.today_outlined,
                        color: AppColors.warning,
                        prominent: true,
                        onTap: () => Get.toNamed(AppRoutes.todaysWork),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addClient.tr,
                        icon: Icons.person_add_alt_1_outlined,
                        color: AppColors.primary,
                        prominent: true,
                        onTap: () => Get.toNamed(AppRoutes.clientForm),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addPolicy.tr,
                        icon: Icons.note_add_outlined,
                        color: AppColors.heroBlue,
                        prominent: true,
                        onTap: () => showAddPolicyMethodSheet(),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.addFollowUp.tr,
                        icon: Icons.add_alert_outlined,
                        color: AppColors.priority,
                        prominent: true,
                        onTap: () => Get.toNamed(AppRoutes.followUpForm),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  DashboardActionGroup(
                    title: TranslationKeys.secondaryTools.tr,
                    children: [
                      DashboardQuickAction(
                        label: TranslationKeys.exportClients.tr,
                        icon: Icons.file_download_outlined,
                        color: AppColors.actionSecondary,
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
                        color: AppColors.slate,
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
                        label: TranslationKeys.viewRenewals.tr,
                        icon: Icons.notifications_active_outlined,
                        color: AppColors.info,
                        onTap: () => Get.toNamed(
                          AppRoutes.reminders,
                          arguments: {'filter': 'pending'},
                        ),
                      ),
                      DashboardQuickAction(
                        label: TranslationKeys.agents.tr,
                        icon: Icons.manage_accounts_outlined,
                        color: AppColors.actionPrimary,
                        onTap: () => Get.toNamed(AppRoutes.agentList),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionGap),
                  SectionTitle(
                    title: TranslationKeys.upcomingDates.tr,
                    subtitle: TranslationKeys.upcomingDatesSubtitle.tr,
                  ),
                  SizedBox(height: responsive.itemGap),
                  Obx(() {
                    if (controller.upcomingEvents.isEmpty) {
                      return Text(TranslationKeys.noUpcomingDates.tr);
                    }
                    return Column(
                      children: controller.upcomingEvents
                          .map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: UpcomingWorkCard(
                                title: event.clientName,
                                label: event.label,
                                dateLabel: DateFormat('dd MMM').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    event.eventDateMs,
                                  ),
                                ),
                                trailingLabel: event.mobile,
                                icon: event.eventType == 'birthday'
                                    ? Icons.cake_outlined
                                    : Icons.event_outlined,
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
