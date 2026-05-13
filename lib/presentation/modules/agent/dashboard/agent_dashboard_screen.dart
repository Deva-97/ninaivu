import 'package:flutter/material.dart';

class AgentDashboardScreen extends StatelessWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DashboardCard(title: 'My Clients', value: '0'),
          _DashboardCard(title: 'My Policies', value: '0'),
          _DashboardCard(title: 'Renewals Today', value: '0'),
          _DashboardCard(title: 'Follow-ups Today', value: '0'),
        ],
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
