import '../home_screen_content/home_screen_content_controller.dart';
import '../flexes/flexes_controller.dart'; // Import the new controller

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppShellController());
    Get.lazyPut(() => HomeScreenContentController());
    Get.lazyPut(() => FlexesController()); // Add the new controller here
  }
}
