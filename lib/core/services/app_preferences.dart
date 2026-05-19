import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'role';
  static const String _businessIdKey = 'business_id';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _appLockPinHashKey = 'app_lock_pin_hash';
  static const String _biometricUnlockEnabledKey = 'biometric_unlock_enabled';

  static AppPreferences? _instance;
  static final StreamController<int?> _lastSyncTimeController =
      StreamController<int?>.broadcast();

  static AppPreferences? get currentInstance => _instance;
  static Stream<int?> get lastSyncTimeStream => _lastSyncTimeController.stream;

  static Future<AppPreferences> getInstance() async {
    if (_instance != null) {
      return _instance!;
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    _instance = AppPreferences._(sharedPreferences);
    return _instance!;
  }

  String? get userId => _sharedPreferences.getString(_userIdKey);
  String? get role => _sharedPreferences.getString(_roleKey);
  String? get businessId => _sharedPreferences.getString(_businessIdKey);
  int? get lastSyncTime => _sharedPreferences.getInt(_lastSyncTimeKey);
  bool get isAppLockEnabled =>
      _sharedPreferences.getBool(_appLockEnabledKey) ?? false;
  String? get appLockPinHash => _sharedPreferences.getString(_appLockPinHashKey);
  bool get isBiometricUnlockEnabled =>
      _sharedPreferences.getBool(_biometricUnlockEnabledKey) ?? false;

  Future<void> setUserId(String? value) async {
    await _setOrRemoveString(_userIdKey, value);
  }

  Future<void> setRole(String? value) async {
    await _setOrRemoveString(_roleKey, value);
  }

  Future<void> setBusinessId(String? value) async {
    await _setOrRemoveString(_businessIdKey, value);
  }

  Future<void> setLastSyncTime(int? value) async {
    if (value == null) {
      await _sharedPreferences.remove(_lastSyncTimeKey);
      _lastSyncTimeController.add(null);
      return;
    }

    await _sharedPreferences.setInt(_lastSyncTimeKey, value);
    _lastSyncTimeController.add(value);
  }

  Future<void> setAppLockEnabled(bool value) async {
    await _sharedPreferences.setBool(_appLockEnabledKey, value);
  }

  Future<void> setAppLockPinHash(String? value) async {
    await _setOrRemoveString(_appLockPinHashKey, value);
  }

  Future<void> setBiometricUnlockEnabled(bool value) async {
    await _sharedPreferences.setBool(_biometricUnlockEnabledKey, value);
  }

  Future<void> saveSession({
    required String userId,
    required String role,
    required String businessId,
  }) async {
    await setUserId(userId);
    await setRole(role);
    await setBusinessId(businessId);
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(_userIdKey);
    await _sharedPreferences.remove(_roleKey);
    await _sharedPreferences.remove(_businessIdKey);
    await _sharedPreferences.remove(_lastSyncTimeKey);
    _lastSyncTimeController.add(null);
  }

  Future<void> _setOrRemoveString(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _sharedPreferences.remove(key);
      return;
    }

    await _sharedPreferences.setString(key, value);
  }
}
