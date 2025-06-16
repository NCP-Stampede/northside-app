// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Your project's specific import file for Get, Sizer, etc.
// This path must match your project structure.
import 'core/app_export.dart'; 

void main() {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock screen orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Sizer provides responsive screen and font sizes
    return Sizer(
      builder: (context, orientation, deviceType) {
        // GetMaterialApp is the heart of your GetX navigation and state management
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme, // Uses the theme defined in your project
          locale: Locale('en', ''),
          fallbackLocale: Locale('en', ''),
          title: 'Northside App', // Changed title to be more specific
          
          // This tells GetX to start your app at the route defined as 
          // 'initialRoute' in your AppRoutes file.
          initialRoute: AppRoutes.initialRoute,
          
          // This gives GetX the list of all possible pages in your app.
          getPages: AppRoutes.pages,
          
          // This builder is used to lock the text scale factor.
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}