import 'package:get/get.dart';
import '../controllers/root_controller.dart';
import '../../home/bindings/home_binding.dart';
import '../../notifications/bindings/notifications_binding.dart';
import '../../settings/bindings/settings_binding.dart';
import '../../profile/bindings/profile_binding.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(() => RootController());
    HomeBinding().dependencies();
    NotificationsBinding().dependencies();
    SettingsBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
