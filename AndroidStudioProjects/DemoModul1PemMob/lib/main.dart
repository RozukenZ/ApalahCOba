import 'package:demomodul1pemmob/app/views/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/models/firebase_options.dart';
import 'app/services/notification_handler.dart';
import 'app/views/logreg/login_page.dart';
import 'app/views/logreg/register_page.dart';
import 'app/views/welcome_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() async => await SharedPreferences.getInstance());
  await FirebaseMessagingHandler().initPushNotification();
  runApp(const MyApp());
  await FirebaseMessagingHandler().initLocalNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Message App',
      theme: ThemeData.dark(),
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomePage()),  // Halaman welcome
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),  // Halaman register
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}
