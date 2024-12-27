import 'package:demomodul1pemmob/app/views/community/community.dart';
import 'package:demomodul1pemmob/app/views/story/story_page.dart';
import 'package:demomodul1pemmob/app/views/weather/weather_screen.dart';
import 'chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default to "Pesan"
  final AuthController _authController = Get.put(AuthController());
  // List of widgets for each tab
  final List<Widget> _widgetOptions = [
    CommunityScreen(
      url: 'https://blog.whatsapp.com/',
    ),
    const ChatScreen(),
    const StoryScreen(),
    WeatherScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OurChat'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed(AppRoutes.settings);
            },
          ),

          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Menampilkan dialog konfirmasi logout
              _showLogoutConfirmationDialog(context);
            },
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Cerita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Cuaca', // Tab baru
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Menonaktifkan penutupan dialog dengan klik di luar dialog
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Membuat sudut dialog lebih melengkung
          ),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.exit_to_app, // Ikon logout
                  size: 50,
                  color: Colors.green, // Ikon berwarna hijau
                ),
                const SizedBox(height: 20),
                const Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // Teks hijau
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Cancel dengan warna hijau muda
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Menutup dialog tanpa melakukan logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade200, // Background hijau muda
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    // Tombol Logout dengan warna hijau gelap
                    ElevatedButton(
                      onPressed: () {
                        _authController.logout(); // Melakukan logout
                        Navigator.of(context).pop(); // Menutup dialog setelah logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Warna hijau gelap
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



}


