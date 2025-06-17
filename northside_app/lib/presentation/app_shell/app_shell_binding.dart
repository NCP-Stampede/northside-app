import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_controller.dart';
import 'package:northside_app/presentation/home_screen_content/home_screen_content_controller.dart';
import 'package:northside_app/presentation/athletics_screen/athletics_controller.dart';
import 'package:northside_app/presentation/attendance_screen/attendance_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    // This controller manages the nav bar state and is always available.
    Get.lazyPut(() => AppShellController());

    // These controllers are for the content pages.
    Get.lazyPut(() => HomeScreenContentController());
    Get.lazyPut(() => AthleticsController());
    Get.lazyPut(() => AttendanceController());
  }
}
