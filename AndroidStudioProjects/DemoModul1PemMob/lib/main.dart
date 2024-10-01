import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/views/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WhatsApp Settings',
      theme: ThemeData.dark(),
      home: SettingsScreen(),
    );
  }
}