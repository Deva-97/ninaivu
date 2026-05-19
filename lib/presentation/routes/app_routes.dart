abstract class AppRoutes {
  AppRoutes._();

  static const splashScreen = '/';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const profileSetup = '/profile-setup';

  static const String adminDashboard = '/admin-dashboard';
  static const String agentDashboard = '/agent-dashboard';

  static const String agentList = '/admin/agents';
  static const String addEditAgent = '/admin/agents/form';
  static const String customerList = '/admin/customers';
  static const String addEditCustomer = '/admin/customers/form';

  static const String clients = '/clients';
  static const String clientForm = '/clients/form';
  static const String clientDetails = '/clients/details';

  static const String policies = '/policies';
  static const String policyForm = '/policies/form';
  static const String policyDetails = '/policies/details';

  static const String reminders = '/reminders';
  static const String reminderDetails = '/reminders/details';
  static const String todaysWork = '/todays-work';
  static const String followUps = '/follow-ups';
  static const String followUpForm = '/follow-ups/form';
  static const String followUpDetails = '/follow-ups/details';
}
