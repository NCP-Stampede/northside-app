import 'package:get/get.dart';

class AppShellController extends GetxController {
  // Reactive variable to hold the selected navigation bar index.
  final RxInt navBarIndex = 0.obs;

  // Function to update the index when a nav item is tapped.
  void changePage(int index) {
    navBarIndex.value = index;
  }
} 
