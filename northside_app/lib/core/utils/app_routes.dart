// lib/core/utils/app_routes.dart

import 'package:get/get.dart';
// We will create all these imported files in the next steps.
import 'package:northside_app/presentation/app_shell/app_shell_screen.dart';
import 'package:northside_app/presentation/app_shell/app_shell_binding.dart';

class AppRoutes {
  // The app will launch and immediately go to the AppShellScreen.
  static const String initialRoute = '/app_shell';

  static List<GetPage> pages = [
    GetPage(
      name: initialRoute,
      page: () => const AppShellScreen(),
      // The binding injects the necessary controllers for the shell and its children.
      binding: AppShellBinding(),
    ),
    // TODO: Add other pages here later, like detail pages
    // GetPage(name: '/events_detail', page: () => EventsDetailPage()),
  ];
}
