// lib/presentation/app_shell/app_shell_binding.dart

import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    // This makes sure that an AppShellController is available
    // for the AppShellScreen and its children.
    Get.lazyPut(() => AppShellController());
  }
}
