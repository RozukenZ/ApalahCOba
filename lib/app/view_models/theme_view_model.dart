import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void toggleTheme(bool isDarkMode) async {
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);

    // Simpan preferensi tema
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default ke dark mode
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }
}
