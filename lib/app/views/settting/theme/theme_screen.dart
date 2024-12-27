import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/app/view_models/theme_view_model.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return RadioListTile<bool>(
                title: const Text('Light Mode'),
                value: false,
                groupValue: themeController.themeMode.value == ThemeMode.dark,
                onChanged: (value) {
                  themeController.toggleTheme(value!);
                },
              );
            }),
            Obx(() {
              return RadioListTile<bool>(
                title: const Text('Dark Mode'),
                value: true,
                groupValue: themeController.themeMode.value == ThemeMode.dark,
                onChanged: (value) {
                  themeController.toggleTheme(value!);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
