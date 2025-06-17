import 'package:get/get.dart';

class AppShellController extends GetxController {
  // .obs makes this variable "reactive." The UI will auto-update when it changes.
  final RxInt navBarIndex = 0.obs;

  void changePage(int index) {
    navBarIndex.value = index;
  }
}
