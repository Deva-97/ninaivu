import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ninaivu/core/database/database_helper.dart';
import 'package:ninaivu/core/services/app_lock_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/app_settings_service.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/services/import_export_service.dart';
import 'package:ninaivu/core/services/profile_image_service.dart';
import 'package:ninaivu/data/repositories/user_repository_impl.dart';
import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/usecases/users/update_current_user_profile_image_usecase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';

/// Controller behind the settings screen.
///
/// It collects profile details, sync diagnostics, import/export actions, and
/// maintenance operations so the widget tree stays mostly declarative.
class SettingsController extends GetxController {
  SettingsController({
    AuthService? authService,
    UserRepositoryImpl? userRepository,
    AppSettingsService? appSettingsService,
    ProfileImageService? profileImageService,
    ImportExportService? importExportService,
    DatabaseHelper? databaseHelper,
    AppLockService? appLockService,
  }) : _authService = authService ?? AuthService(),
       _userRepository = userRepository ?? UserRepositoryImpl(),
       _appSettingsService =
           appSettingsService ?? Get.find<AppSettingsService>(),
       _profileImageService = profileImageService ?? ProfileImageService(),
       _importExportService = importExportService ?? ImportExportService(),
       _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
       _appLockService = appLockService ?? Get.find<AppLockService>();

  final AuthService _authService;
  final UserRepositoryImpl _userRepository;
  final AppSettingsService _appSettingsService;
  final ProfileImageService _profileImageService;
  final ImportExportService _importExportService;
  final DatabaseHelper _databaseHelper;
  final AppLockService _appLockService;

  late final UpdateCurrentUserProfileImageUseCase
  _updateCurrentUserProfileImageUseCase = UpdateCurrentUserProfileImageUseCase(
    _userRepository,
  );

  final currentUser = Rxn<AppUser>();
  final isLoading = false.obs;
  final pendingSyncCount = 0.obs;
  final lastSyncText = 'Never synced'.obs;
  final versionText = ''.obs;

  AppSettingsService get settings => _appSettingsService;
  AppLockService get appLockService => _appLockService;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _userRepository.getCurrentUser(),
        AppPreferences.getInstance(),
        _countPendingSync(),
        PackageInfo.fromPlatform(),
      ]);

      currentUser.value = results[0] as AppUser?;
      final preferences = results[1] as AppPreferences;
      pendingSyncCount.value = results[2] as int;
      final packageInfo = results[3] as PackageInfo;

      final lastSync = preferences.lastSyncTime;
      lastSyncText.value = lastSync == null
          ? 'Never synced'
          : DateTime.fromMillisecondsSinceEpoch(lastSync).toString();
      versionText.value = packageInfo.version;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    final profileImageData = await _profileImageService.pickProfileImageData(
      source: source,
    );
    if (profileImageData == null) {
      return;
    }
    currentUser.value = await _updateCurrentUserProfileImageUseCase(
      profileImageData: profileImageData,
    );
  }

  Future<void> removeProfileImage() async {
    currentUser.value = await _updateCurrentUserProfileImageUseCase(
      removeImage: true,
    );
  }

  Future<void> logout() => _authService.logout();

  Future<void> clearLocalData() async {
    await _databaseHelper.clearLocalBusinessData();
    pendingSyncCount.value = 0;
  }

  Future<void> exportClientsCsv() => _importExportService.exportClientsCsv();
  Future<void> exportPoliciesCsv() => _importExportService.exportPoliciesCsv();
  Future<void> exportFollowUpsCsv() =>
      _importExportService.exportFollowUpsCsv();
  Future<void> exportRemindersCsv() =>
      _importExportService.exportRemindersCsv();

  Future<int> _countPendingSync() async {
    final db = await _databaseHelper.database;
    // Failed rows are included so support/debugging can see records that need a
    // retry even if they have already exhausted one or more sync attempts.
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM sync_queue WHERE sync_status IN (?, ?, ?, ?)',
      ['pending_create', 'pending_update', 'pending_delete', 'failed'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
