import 'package:get/get.dart';
import 'package:ninaivu/presentation/bindings/admin_user_bindings.dart';
import 'package:ninaivu/presentation/bindings/client_bindings.dart';
import 'package:ninaivu/presentation/bindings/dashboard_bindings.dart';
import 'package:ninaivu/presentation/bindings/follow_up_bindings.dart';
import 'package:ninaivu/presentation/bindings/policy_bindings.dart';
import 'package:ninaivu/presentation/bindings/reminder_bindings.dart';
import 'package:ninaivu/presentation/bindings/todays_work_binding.dart';
import 'package:ninaivu/presentation/modules/admin/dashboard/admin_dashboard_screen.dart';
import 'package:ninaivu/presentation/modules/admin/users/add_edit_agent_screen.dart';
import 'package:ninaivu/presentation/modules/admin/users/agent_list_screen.dart';
import 'package:ninaivu/presentation/modules/agent/dashboard/agent_dashboard_screen.dart';
import 'package:ninaivu/presentation/modules/clients/add_edit_client_screen.dart';
import 'package:ninaivu/presentation/modules/clients/client_detail_screen.dart';
import 'package:ninaivu/presentation/modules/clients/client_list_screen.dart';
import 'package:ninaivu/presentation/modules/common/auth/login_screen.dart';
import 'package:ninaivu/presentation/modules/common/auth/otp_verification_screen.dart';
import 'package:ninaivu/presentation/modules/common/auth/profile_setup_screen.dart';
import 'package:ninaivu/presentation/modules/common/splash/splash_screen.dart';
import 'package:ninaivu/presentation/modules/common/todays_work/todays_work_screen.dart';
import 'package:ninaivu/presentation/modules/follow_ups/add_edit_follow_up_screen.dart';
import 'package:ninaivu/presentation/modules/follow_ups/follow_up_detail_screen.dart';
import 'package:ninaivu/presentation/modules/follow_ups/follow_up_list_screen.dart';
import 'package:ninaivu/presentation/modules/policies/add_edit_policy_screen.dart';
import 'package:ninaivu/presentation/modules/policies/policy_detail_screen.dart';
import 'package:ninaivu/presentation/modules/policies/policy_list_screen.dart';
import 'package:ninaivu/presentation/modules/reminders/reminder_detail_screen.dart';
import 'package:ninaivu/presentation/modules/reminders/reminder_list_screen.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:ninaivu/presentation/routes/route_middleware.dart';

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
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.agentDashboard,
      page: () => const AgentDashboardScreen(),
      binding: AgentDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.agentList,
      page: () => const AgentListScreen(),
      binding: AgentListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.addEditAgent,
      page: () => const AddEditAgentScreen(),
      binding: AgentFormBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.customerList,
      page: () => const CustomerListScreen(),
      binding: CustomerListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.addEditCustomer,
      page: () => const AddEditCustomerScreen(),
      binding: CustomerFormBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.clients,
      page: () => const ClientListScreen(),
      binding: ClientListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.clientForm,
      page: () => const AddEditClientScreen(),
      binding: ClientFormBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.clientDetails,
      page: () => const ClientDetailScreen(),
      binding: ClientDetailBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.policies,
      page: () => const PolicyListScreen(),
      binding: PolicyListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.policyForm,
      page: () => const AddEditPolicyScreen(),
      binding: PolicyFormBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.policyDetails,
      page: () => const PolicyDetailScreen(),
      binding: PolicyDetailBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.todaysWork,
      page: () => const TodaysWorkScreen(),
      binding: TodaysWorkBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.reminders,
      page: () => const ReminderListScreen(),
      binding: ReminderListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.reminderDetails,
      page: () => const ReminderDetailScreen(),
      binding: ReminderDetailBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.followUps,
      page: () => const FollowUpListScreen(),
      binding: FollowUpListBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.followUpForm,
      page: () => const AddEditFollowUpScreen(),
      binding: FollowUpFormBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
    GetPage(
      name: AppRoutes.followUpDetails,
      page: () => const FollowUpDetailScreen(),
      binding: FollowUpDetailBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: const ['admin', 'agent']),
      ],
    ),
  ];
}
