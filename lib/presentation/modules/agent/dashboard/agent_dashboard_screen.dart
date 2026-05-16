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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          Obx(
            () => TextButton.icon(
              onPressed: controller.isSigningOut.value ? null : controller.signOut,
              icon: controller.isSigningOut.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(
                controller.isSigningOut.value ? 'Signing out...' : 'Sign out',
              ),
            ),
          ),
          const SizedBox(width: 8),
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Your portfolio',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Track your renewals and follow-ups from live SQLite data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 720 ? 3 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.08,
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
              const SizedBox(height: 24),
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
                      arguments: {'filter': 'upcoming7days'},
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
