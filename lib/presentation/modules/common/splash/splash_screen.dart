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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final backgroundColors = isDark
        ? const [Color(0xFF020617), Color(0xFF0F1F4A)]
        : const [Color(0xFFFDFEFF), Color(0xFFE8F0FF)];
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final loaderColor = isDark ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
        ),
        child: Center(
          child: ResponsiveContent(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLogo(
                    size: responsive.scaled(180, min: 140),
                    semanticLabel: AppConstants.appName,
                  ),
                  SizedBox(height: responsive.scaled(18, min: 14)),
                  Text(
                    AppStrings.splashTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: responsive.headlineSize,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: responsive.scaled(8, min: 6)),
                  Text(
                    AppStrings.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtitleColor),
                  ),
                  SizedBox(height: responsive.scaled(28, min: 20)),
                  SizedBox(
                    width: responsive.scaled(28, min: 24),
                    height: responsive.scaled(28, min: 24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
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
