import 'package:demomodul1pemmob/app/models/firebase_options.dart';
import 'package:demomodul1pemmob/app/services/notification_handler.dart';
import 'package:demomodul1pemmob/app/routes/app_routes.dart';
import 'package:demomodul1pemmob/app/view_models/theme_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/controller/connectivity_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() async => await SharedPreferences.getInstance());
  await GetStorage.init();
  Get.put(ConnectivityController());
  await FirebaseMessagingHandler().initPushNotification();

  Get.put(ThemeViewModel());

  runApp(const MyApp());

  // Initialize Local Notifications
  await FirebaseMessagingHandler().initLocalNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeViewModel>();

    return Obx(() {
      return GetMaterialApp(
        title: 'Message App',
        themeMode: themeController.themeMode.value,
        // Light Theme
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black), // Main text color
            bodyMedium: TextStyle(color: Colors.black54), // Subtitle text color
          ),
          iconTheme: const IconThemeData(color: Colors.black), // Icon color
        ),
        // Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white), // Main text color
            bodyMedium: TextStyle(color: Colors.white70), // Subtitle text color
          ),
          iconTheme: const IconThemeData(color: Colors.white), // Icon color
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
      );
    });
  }
}
