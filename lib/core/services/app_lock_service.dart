import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ninaivu/core/services/app_preferences.dart';

class AppLockService extends GetxService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  static const Duration _resumeLockGracePeriod = Duration(seconds: 15);

  final isEnabled = false.obs;
  final isLocked = false.obs;
  final isBiometricEnabled = false.obs;
  final isBiometricAvailable = false.obs;

  String? _pinHash;
  DateTime? _backgroundedAt;
  bool _isAuthenticatingWithBiometric = false;

  Future<AppLockService> init() async {
    final preferences = await AppPreferences.getInstance();
    _pinHash = preferences.appLockPinHash;
    isEnabled.value =
        preferences.isAppLockEnabled && (_pinHash?.isNotEmpty == true);
    isBiometricEnabled.value = preferences.isBiometricUnlockEnabled;
    isBiometricAvailable.value = await _canUseBiometric();
    isLocked.value = isEnabled.value;
    return this;
  }

  Future<void> savePin({
    required String pin,
    required bool enableBiometric,
  }) async {
    final preferences = await AppPreferences.getInstance();
    _pinHash = _hashPin(pin);
    await preferences.setAppLockPinHash(_pinHash);
    await preferences.setAppLockEnabled(true);
    await preferences.setBiometricUnlockEnabled(enableBiometric);
    isEnabled.value = true;
    isBiometricEnabled.value = enableBiometric;
    isLocked.value = false;
  }

  Future<void> disable() async {
    final preferences = await AppPreferences.getInstance();
    await preferences.setAppLockEnabled(false);
    await preferences.setAppLockPinHash(null);
    await preferences.setBiometricUnlockEnabled(false);
    _pinHash = null;
    isEnabled.value = false;
    isBiometricEnabled.value = false;
    isLocked.value = false;
  }

  void lockIfEnabled() {
    if (isEnabled.value) {
      isLocked.value = true;
    }
  }

  void markAppBackgrounded() {
    if (!isEnabled.value || _isAuthenticatingWithBiometric) {
      return;
    }

    _backgroundedAt ??= DateTime.now();
  }

  void handleAppResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;

    if (!isEnabled.value || backgroundedAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(backgroundedAt);
    if (elapsed >= _resumeLockGracePeriod) {
      isLocked.value = true;
    }
  }

  Future<bool> unlockWithBiometric() async {
    if (!isEnabled.value || !isBiometricEnabled.value) {
      return false;
    }
    final canUse = await _canUseBiometric();
    if (!canUse) {
      return false;
    }

    _isAuthenticatingWithBiometric = true;
    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock Ninaivu',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        isLocked.value = false;
      }
      return authenticated;
    } on PlatformException catch (error) {
      if (error.code == 'no_fragment_activity') {
        isBiometricAvailable.value = false;
      }
      return false;
    } finally {
      _isAuthenticatingWithBiometric = false;
    }
  }

  bool verifyPin(String pin) {
    final isValid = _pinHash != null && _hashPin(pin) == _pinHash;
    if (isValid) {
      isLocked.value = false;
    }
    return isValid;
  }

  String _hashPin(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> _canUseBiometric() async {
    try {
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final isSupported = await _localAuthentication.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }
}
