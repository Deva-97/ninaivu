import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:insurance_reminders/presentation/modules/admin/dashboard/admin_dashboard_screen.dart';
import 'package:insurance_reminders/presentation/modules/agent/dashboard/agent_dashboard_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/login_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/otp_verification_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/profile_setup_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/splash/splash_screen.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.agentDashboard,
      page: () => const AgentDashboardScreen(),
    ),
  ];
}
