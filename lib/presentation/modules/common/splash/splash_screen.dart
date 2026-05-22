import 'package:flutter/material.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/app_constants.dart';
import 'package:ninaivu/core/constants/app_strings.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/widgets/app_logo.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ResponsiveContent(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.scaled(24, min: 20)),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSoft
                          : AppColors.lightPrimaryContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: AppLogo(
                      size: responsive.scaled(118, min: 102),
                      semanticLabel: AppConstants.appName,
                    ),
                  ),
                  SizedBox(height: responsive.scaled(28, min: 24)),
                  Text(
                    AppStrings.splashTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  SizedBox(height: responsive.scaled(8, min: 6)),
                  Text(
                    AppStrings.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: responsive.scaled(28, min: 24)),
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
