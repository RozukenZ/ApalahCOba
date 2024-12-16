import 'package:demomodul1pemmob/app/models/firebase_options.dart';
import 'package:demomodul1pemmob/app/services/notification_handler.dart';
import 'package:demomodul1pemmob/app/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/controller/connectivity_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize SharedPreferences
  await Get.putAsync(() async => await SharedPreferences.getInstance());

  // Initialize Connectivity Controller
  Get.put(ConnectivityController());

  // Initialize Push Notifications
  await FirebaseMessagingHandler().initPushNotification();

  // Run the app
  runApp(const MyApp());

  // Initialize Local Notifications
  await FirebaseMessagingHandler().initLocalNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Message App',
      theme: ThemeData.dark(),
      initialRoute: AppRoutes.welcome,
      getPages: AppRoutes.routes,
    );
  }
}