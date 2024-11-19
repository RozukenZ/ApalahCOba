import 'package:demomodul1pemmob/app/views/community/community.dart';
import 'package:demomodul1pemmob/app/views/story/story_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/app/views/settting/settings_screen.dart';
import 'VoiceNote/VoiceNoteWidget.dart';
import 'chat/chat_screen.dart';
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
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menampilkan Voice Note
  void _showVoiceNote() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: VoiceNoteWidget(), // Gunakan VoiceNoteWidget
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp UI'),
        backgroundColor: Colors.green,
        actions: [
          // Tombol Voice Note baru
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _showVoiceNote, // Panggil fungsi untuk menampilkan Voice Note
            tooltip: 'Voice Note',
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Tindakan ketika tombol pengaturan ditekan
              Get.to(SettingsScreen());
            },
          ),

          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _authController.logout(); // Panggil fungsi logout ketika tombol ditekan.
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