import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:insurance_reminders/presentation/bindings/admin_user_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/client_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/policy_bindings.dart';
import 'package:insurance_reminders/presentation/modules/admin/dashboard/admin_dashboard_screen.dart';
import 'package:insurance_reminders/presentation/modules/admin/users/add_edit_agent_screen.dart';
import 'package:insurance_reminders/presentation/modules/admin/users/agent_list_screen.dart';
import 'package:insurance_reminders/presentation/modules/agent/dashboard/agent_dashboard_screen.dart';
import 'package:insurance_reminders/presentation/modules/clients/add_edit_client_screen.dart';
import 'package:insurance_reminders/presentation/modules/clients/client_detail_screen.dart';
import 'package:insurance_reminders/presentation/modules/clients/client_list_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/login_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/otp_verification_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/auth/profile_setup_screen.dart';
import 'package:insurance_reminders/presentation/modules/common/splash/splash_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/add_edit_policy_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/policy_detail_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/policy_list_screen.dart';
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
    GetPage(
      name: AppRoutes.agentList,
      page: () => const AgentListScreen(),
      binding: AgentListBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditAgent,
      page: () => const AddEditAgentScreen(),
      binding: AgentFormBinding(),
    ),
    GetPage(
      name: AppRoutes.customerList,
      page: () => const CustomerListScreen(),
      binding: CustomerListBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditCustomer,
      page: () => const AddEditCustomerScreen(),
      binding: CustomerFormBinding(),
    ),
    GetPage(
      name: AppRoutes.clients,
      page: () => const ClientListScreen(),
      binding: ClientListBinding(),
    ),
    GetPage(
      name: AppRoutes.clientForm,
      page: () => const AddEditClientScreen(),
      binding: ClientFormBinding(),
    ),
    GetPage(
      name: AppRoutes.clientDetails,
      page: () => const ClientDetailScreen(),
      binding: ClientDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.policies,
      page: () => const PolicyListScreen(),
      binding: PolicyListBinding(),
    ),
    GetPage(
      name: AppRoutes.policyForm,
      page: () => const AddEditPolicyScreen(),
      binding: PolicyFormBinding(),
    ),
    GetPage(
      name: AppRoutes.policyDetails,
      page: () => const PolicyDetailScreen(),
      binding: PolicyDetailBinding(),
    ),
  ];
}
