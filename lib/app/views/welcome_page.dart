import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../controller/auth_controller.dart';  // Import AuthController

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Obx(() {
        // Menunggu status login untuk memutuskan apakah perlu menampilkan halaman login/register
        if (authController.isLoggedIn.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.home); // Navigasi ke halaman home
          });
          return const Center(child: CircularProgressIndicator()); // Menampilkan loading saat proses cek login
        } else {
          // Jika belum login, tampilkan UI login/register
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/chat.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'SELAMAT DATANG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);  // Navigasi ke halaman login
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.register);  // Navigasi ke halaman register
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
