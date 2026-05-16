import 'package:flutter/material.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();

  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);

    try {
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: Text(_isSigningOut ? 'Signing out...' : 'Sign out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSigningOut,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _DashboardCard(title: 'Total Agents', value: '0'),
            const _DashboardCard(title: 'Total Clients', value: '0'),
            const _DashboardCard(title: 'Total Policies', value: '0'),
            const _DashboardCard(title: 'Renewals Today', value: '0'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  label: 'Agents',
                  icon: Icons.manage_accounts_outlined,
                  onTap: () => Get.toNamed(AppRoutes.agentList),
                ),
                _QuickActionButton(
                  label: 'Customers',
                  icon: Icons.groups_outlined,
                  onTap: () => Get.toNamed(AppRoutes.customerList),
                ),
                _QuickActionButton(
                  label: 'Clients',
                  icon: Icons.people_outline_rounded,
                  onTap: () => Get.toNamed(AppRoutes.clients),
                ),
                _QuickActionButton(
                  label: 'Policies',
                  icon: Icons.description_outlined,
                  onTap: () => Get.toNamed(AppRoutes.policies),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const _DashboardCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
