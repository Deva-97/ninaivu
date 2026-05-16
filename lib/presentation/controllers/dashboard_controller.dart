import 'package:get/get.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';

abstract class DashboardController<T> extends GetxController {
  DashboardController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  final isLoading = false.obs;
  final isSigningOut = false.obs;
  final errorMessage = RxnString();

  Future<void> loadDashboard();

  Future<void> signOut() async {
    if (isSigningOut.value) {
      return;
    }

    isSigningOut.value = true;
    try {
      await _authService.logout();
    } catch (e) {
      Get.snackbar('Unable to sign out', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSigningOut.value = false;
    }
  }
}
