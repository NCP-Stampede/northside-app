import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_binding.dart';
import 'package:northside_app/presentation/app_shell/app_shell_screen.dart';

class AppRoutes {
  // We define the starting point of the app here.
  static const String initialRoute = '/app_shell';

  static List<GetPage> pages = [
    GetPage(
      name: initialRoute,
      page: () => const AppShellScreen(),
      // The binding provides the necessary controllers to the AppShell.
      binding: AppShellBinding(),
    ),
    // Later, you can add routes to detail pages here, for example:
    // GetPage(name: '/homecoming_details', page: () => HomecomingDetailPage()),
  ];
}
