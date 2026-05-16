import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:insurance_reminders/presentation/bindings/admin_user_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/client_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/dashboard_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/follow_up_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/policy_bindings.dart';
import 'package:insurance_reminders/presentation/bindings/reminder_bindings.dart';
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
import 'package:insurance_reminders/presentation/modules/follow_ups/add_edit_follow_up_screen.dart';
import 'package:insurance_reminders/presentation/modules/follow_ups/follow_up_detail_screen.dart';
import 'package:insurance_reminders/presentation/modules/follow_ups/follow_up_list_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/add_edit_policy_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/policy_detail_screen.dart';
import 'package:insurance_reminders/presentation/modules/policies/policy_list_screen.dart';
import 'package:insurance_reminders/presentation/modules/reminders/reminder_detail_screen.dart';
import 'package:insurance_reminders/presentation/modules/reminders/reminder_list_screen.dart';
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
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.agentDashboard,
      page: () => const AgentDashboardScreen(),
      binding: AgentDashboardBinding(),
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
    GetPage(
      name: AppRoutes.reminders,
      page: () => const ReminderListScreen(),
      binding: ReminderListBinding(),
    ),
    GetPage(
      name: AppRoutes.reminderDetails,
      page: () => const ReminderDetailScreen(),
      binding: ReminderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.followUps,
      page: () => const FollowUpListScreen(),
      binding: FollowUpListBinding(),
    ),
    GetPage(
      name: AppRoutes.followUpForm,
      page: () => const AddEditFollowUpScreen(),
      binding: FollowUpFormBinding(),
    ),
    GetPage(
      name: AppRoutes.followUpDetails,
      page: () => const FollowUpDetailScreen(),
      binding: FollowUpDetailBinding(),
    ),
  ];
}
