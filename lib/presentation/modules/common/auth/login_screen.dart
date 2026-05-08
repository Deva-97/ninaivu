import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Welcome to Ninaivu',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              'Insurance reminder and policy management app',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.adminDashboard);
              },
              child: const Text('Continue as Admin'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.agentDashboard);
              },
              child: const Text('Continue as Agent'),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
