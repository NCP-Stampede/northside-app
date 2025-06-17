import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:northside_app/core/utils/app_routes.dart';
import 'package:northside_app/theme/theme_helper.dart';

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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          title: 'northside_app',
          // We remove initialBinding because our GetPage routes will handle their own.
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}
