import 'package:flutter/material.dart';
import 'package:insurance_reminders/core/constants/app_strings.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';
import 'package:insurance_reminders/core/widgets/responsive_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startAuthCheck();
  }

  Future<void> _startAuthCheck() async {
    try {
      await _authService.checkAuthFromSplash();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final responsive = context.responsive;

    return Scaffold(
      body: Center(
        child: ResponsiveContent(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: responsive.scaled(76, min: 60),
                  color: colorScheme.primary,
                ),
                SizedBox(height: responsive.scaled(18, min: 14)),
                Text(
                  AppStrings.splashTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.headlineSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.scaled(8, min: 6)),
                const Text(
                  AppStrings.splashSubtitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.scaled(28, min: 20)),
                SizedBox(
                  width: responsive.scaled(28, min: 24),
                  height: responsive.scaled(28, min: 24),
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
