import 'package:demomodul1pemmob/app/views/community/community.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/app/views/settting/settings_screen.dart';
import 'chat/chatscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default to "Pesan"

  // List of widgets for each tab
  final List<Widget> _widgetOptions = [
    CommunityScreen(
      url: 'https://blog.whatsapp.com/',
    ),
    ChatScreen(),
    StoryScreen(),
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
        title: Text('WhatsApp UI'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Tindakan ketika tombol pengaturan ditekan
              Get.to(SettingsScreen());
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
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Cerita'),
    );
  }
}
