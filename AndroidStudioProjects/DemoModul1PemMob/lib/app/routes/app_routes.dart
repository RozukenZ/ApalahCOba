import 'package:get/get.dart';
import '../views/home_screen.dart';
import '../views/logreg/login_page.dart';
import '../views/logreg/register_page.dart';
import '../views/settting/settings_screen.dart';
import '../views/welcome_page.dart';

class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const settings = '/settings';

  static final routes = [
    GetPage(name: welcome, page: () => const WelcomePage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: register, page: () => const RegisterPage()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: settings, page: () => SettingsScreen()),
  ];
}
