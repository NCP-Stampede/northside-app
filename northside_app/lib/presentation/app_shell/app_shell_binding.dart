import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_controller.dart';
import 'package:northside_app/presentation/home_screen_content/home_screen_content_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    // Provides the AppShellController to manage nav bar state.
    Get.lazyPut(() => AppShellController());
    // Provides the HomeScreenContentController for the carousel state.
    Get.lazyPut(() => HomeScreenContentController());
  }
}
