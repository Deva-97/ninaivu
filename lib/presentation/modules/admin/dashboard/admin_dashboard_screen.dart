import 'package:flutter/material.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_strings.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/admin_dashboard_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/account_actions_menu.dart';
import 'package:ninaivu/presentation/modules/common/widgets/dashboard_widgets.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        actions: [
          Obx(
            () => IconButton(
              tooltip: controller.isSyncing.value ? 'Syncing' : 'Sync now',
              onPressed: controller.isSyncing.value ? null : controller.syncNow,
              icon: controller.isSyncing.value
                  ? SizedBox(
                      width: responsive.scaled(18, min: 16),
                      height: responsive.scaled(18, min: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
            ),
          ),
          Obx(
            () => AccountActionsMenu(
              onSignOut: controller.signOut,
              isSigningOut: controller.isSigningOut.value,
            ),
          ),
          SizedBox(width: responsive.scaled(4, min: 2)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return const AppLoadingView(message: 'Loading dashboard...');
        }

        final error = controller.errorMessage.value;
        if (error != null && controller.stats.value == null) {
          return AppErrorView(
            title: 'Unable to load dashboard',
            message: error,
            onRetry: controller.loadDashboard,
          );
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return const AppEmptyState(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard unavailable',
            subtitle: 'No dashboard data is available right now.',
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
                'Business overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: responsive.scaled(6, min: 4)),
              Text(
                'Live SQLite counts for renewals, users, clients, policies, and follow-ups.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: responsive.scaled(4, min: 4)),
              Obx(
                () => Text(
                  'Last backup: ${controller.lastSyncLabel.value}',
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
                    title: 'Total Agents',
                    value: stats.totalAgents,
                    icon: Icons.support_agent_rounded,
                    color: Colors.blue,
                  ),
                  DashboardMetricCard(
                    title: 'Total Customers',
                    value: stats.totalCustomers,
                    icon: Icons.groups_2_outlined,
                    color: Colors.teal,
                  ),
                  DashboardMetricCard(
                    title: 'Total Clients',
                    value: stats.totalClients,
                    icon: Icons.people_outline_rounded,
                    color: Colors.indigo,
                  ),
                  DashboardMetricCard(
                    title: 'Total Policies',
                    value: stats.totalPolicies,
                    icon: Icons.description_outlined,
                    color: Colors.deepPurple,
                  ),
                  DashboardMetricCard(
                    title: 'Renewals Today',
                    value: stats.renewalsToday,
                    icon: Icons.today_outlined,
                    color: Colors.orange,
                    badgeLabel: 'Pending',
                  ),
                  DashboardMetricCard(
                    title: 'Upcoming 7 Days',
                    value: stats.upcoming7Days,
                    icon: Icons.upcoming_outlined,
                    color: Colors.cyan,
                  ),
                  DashboardMetricCard(
                    title: 'Expired Policies',
                    value: stats.expiredPolicies,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    badgeLabel: 'Missed',
                  ),
                  DashboardMetricCard(
                    title: 'Pending Follow-ups',
                    value: stats.pendingFollowUps,
                    icon: Icons.pending_actions_outlined,
                    color: Colors.amber,
                    badgeLabel: 'Pending',
                  ),
                  DashboardMetricCard(
                    title: 'Missed Follow-ups',
                    value: stats.missedFollowUps,
                    icon: Icons.history_toggle_off_rounded,
                    color: Colors.pink,
                    badgeLabel: 'Missed',
                  ),
                ],
              ),
              SizedBox(height: responsive.sectionGap),
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: responsive.scaled(12, min: 10)),
              Wrap(
                spacing: responsive.scaled(12, min: 10),
                runSpacing: responsive.scaled(12, min: 10),
                children: [
                  DashboardQuickAction(
                    label: 'Add Client',
                    icon: Icons.person_add_alt_1_outlined,
                    color: Colors.indigo,
                    onTap: () => Get.toNamed(AppRoutes.clientForm),
                  ),
                  DashboardQuickAction(
                    label: 'Add Policy',
                    icon: Icons.note_add_outlined,
                    color: Colors.deepPurple,
                    onTap: () => Get.toNamed(AppRoutes.policyForm),
                  ),
                  DashboardQuickAction(
                    label: 'Add Follow-up',
                    icon: Icons.add_alert_outlined,
                    color: Colors.orange,
                    onTap: () => Get.toNamed(AppRoutes.followUpForm),
                  ),
                  DashboardQuickAction(
                    label: 'View Renewals',
                    icon: Icons.notifications_active_outlined,
                    color: Colors.teal,
                    onTap: () => Get.toNamed(
                      AppRoutes.reminders,
                      arguments: {'filter': 'pending'},
                    ),
                  ),
                  DashboardQuickAction(
                    label: 'Agents',
                    icon: Icons.manage_accounts_outlined,
                    color: Colors.blue,
                    onTap: () => Get.toNamed(AppRoutes.agentList),
                  ),
                  DashboardQuickAction(
                    label: 'Customers',
                    icon: Icons.groups_outlined,
                    color: Colors.green,
                    onTap: () => Get.toNamed(AppRoutes.customerList),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
