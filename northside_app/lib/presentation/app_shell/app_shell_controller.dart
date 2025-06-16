// lib/presentation/app_shell/app_shell_controller.dart

import 'package:get/get.dart';

class AppShellController extends GetxController {
  // .obs makes this variable "observable" or "reactive".
  // The UI will automatically update when its value changes.
  final RxInt navBarIndex = 0.obs;

  // This function changes the page.
  void changePage(int index) {
    navBarIndex.value = index;
  }
}
