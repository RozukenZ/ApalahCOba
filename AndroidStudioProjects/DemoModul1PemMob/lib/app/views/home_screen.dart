import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/app/views/community/community.dart';
import 'package:demomodul1pemmob/app/views/story/story_page.dart';
import 'package:demomodul1pemmob/app/views/settting/settings_screen.dart';
import 'package:demomodul1pemmob/app/views/weather/weather_screen.dart'; // Import halaman cuaca
import '../controller/auth_controller.dart';
import 'chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default ke "Pesan"
  final AuthController _authController = Get.put(AuthController());

  // Tambahkan halaman baru ke list
  final List<Widget> _widgetOptions = [
    CommunityScreen(url: 'https://blog.whatsapp.com/'),
    const ChatScreen(),
    const StoryScreen(),
    WeatherScreen(), // Halaman baru
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
        title: const Text('WhatsApp UI'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(SettingsScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _authController.logout();
            },
          ),
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
}
