import 'package:flutter/material.dart';
import 'package:get/get.dart';

// FIX: Import your AppShellBinding file.
// This path is based on the project structure you showed.
import 'presentation/app_shell/app_shell_binding.dart';
import 'presentation/app_shell/app_shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Northside App',

      // FIX: Use initialBinding to load all necessary controllers at startup.
      // This ensures AppShellController is ready before AppShellScreen is built.
      initialBinding: AppShellBinding(),

      // Your starting screen. Because the binding is now handled by `initialBinding`,
      // you can simply set AppShellScreen as the home widget.
      home: const AppShellScreen(),
    );
  }
}
