import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/agent_dashboard_controller.dart';
import 'package:insurance_reminders/presentation/modules/common/widgets/dashboard_widgets.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class AgentDashboardScreen extends GetView<AgentDashboardController> {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          Obx(
            () => TextButton.icon(
              onPressed: controller.isSyncing.value ? null : controller.syncNow,
              icon: controller.isSyncing.value
                  ? SizedBox(
                      width: responsive.scaled(18, min: 16),
                      height: responsive.scaled(18, min: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(controller.isSyncing.value ? 'Syncing...' : 'Sync now'),
            ),
          ),
          Obx(
            () => TextButton.icon(
              onPressed: controller.isSigningOut.value ? null : controller.signOut,
              icon: controller.isSigningOut.value
                  ? SizedBox(
                      width: responsive.scaled(18, min: 16),
                      height: responsive.scaled(18, min: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(
                controller.isSigningOut.value ? 'Signing out...' : 'Sign out',
              ),
            ),
          ),
          SizedBox(width: responsive.scaled(8, min: 6)),
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
                'Your portfolio',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: responsive.scaled(6, min: 4)),
              Text(
                'Track your renewals and follow-ups from live SQLite data.',
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
                    title: 'My Clients',
                    value: stats.myClients,
                    icon: Icons.people_outline_rounded,
                    color: Colors.indigo,
                  ),
                  DashboardMetricCard(
                    title: 'My Policies',
                    value: stats.myPolicies,
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
                    icon: Icons.date_range_outlined,
                    color: Colors.cyan,
                  ),
                  DashboardMetricCard(
                    title: 'Upcoming 30 Days',
                    value: stats.upcoming30Days,
                    icon: Icons.event_repeat_outlined,
                    color: Colors.teal,
                  ),
                  DashboardMetricCard(
                    title: 'Follow-ups Today',
                    value: stats.followUpsToday,
                    icon: Icons.call_outlined,
                    color: Colors.amber,
                    badgeLabel: 'Pending',
                  ),
                  DashboardMetricCard(
                    title: 'Missed Follow-ups',
                    value: stats.missedFollowUps,
                    icon: Icons.history_toggle_off_rounded,
                    color: Colors.red,
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
