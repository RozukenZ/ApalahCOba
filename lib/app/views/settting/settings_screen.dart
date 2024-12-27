import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/views/settting/account/ganti_nama.dart';
import 'package:demomodul1pemmob/app/views/settting/help/help_setting.dart';
import 'package:demomodul1pemmob/app/views/settting/theme/theme_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demomodul1pemmob/app/view_models/settings_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demomodul1pemmob/app/views/settting/settings_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsViewModel _settingsViewModel = Get.put(SettingsViewModel());

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pilih dari Galeri'),
                    onTap: () {
                      _settingsViewModel.pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Ambil Foto'),
                    onTap: () {
                      _settingsViewModel.pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
        });
  }

  void _showLargeImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _settingsViewModel.profilePicture != null
                  ? FileImage(_settingsViewModel.profilePicture!)
                  : const AssetImage('assets/default_avatar.png')
              as ImageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                if (_settingsViewModel.profilePicture != null) {
                  _showLargeImage(context);
                }
              },
              onLongPress: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: _settingsViewModel.profilePicture != null
                    ? FileImage(_settingsViewModel.profilePicture!)
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            ),
            title: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Text('Error loading name');
                }

                // Mendapatkan data nama dari Firestore
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String name = userData['name'] ?? 'No Name';
                return Text(name);
              },
            ),
            subtitle: const Text('Hey there! I am using OurChat'),
            trailing: const Icon(Icons.qr_code),
          ),
          Divider(color: Colors.grey[800]),
          SettingsListTile(
              icon: Icons.key,
              title: 'Account',
              subtitle: 'Change your Username',
              onTap: () => Get.to(() => UpdateNameScreen()),
          ),
          SettingsListTile(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Dark Mode or Light Mode',
              onTap: () => Get.to(() => ThemeScreen()),
          ),
          SettingsListTile(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Help center, contact us',
              onTap: () => Get.to(() => HelpScreen()),
        ),
        ],
      ),
    );
  }
}
