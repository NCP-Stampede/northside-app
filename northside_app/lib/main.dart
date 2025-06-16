// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming your project structure has these files.
import 'core/app_export.dart';
import 'core/utils/initial_bindings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sizer is used for responsive UI.
    return Sizer(
      builder: (context, orientation, deviceType) {
        // GetMaterialApp is the root of a GetX application.
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          title: 'northside_app',
          // This tells GetX how to inject your controllers.
          initialBinding: InitialBindings(),
          // This tells GetX where to start the app.
          initialRoute: AppRoutes.initialRoute,
          // This gives GetX the list of all pages.
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}
