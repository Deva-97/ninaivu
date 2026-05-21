import 'package:get/get.dart';
import 'package:ninaivu/presentation/controllers/global_search_controller.dart';
import 'package:ninaivu/presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

class GlobalSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GlobalSearchController());
  }
}
