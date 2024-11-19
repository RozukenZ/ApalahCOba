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
                  : const AssetImage('lib/app/assets/default_avatar.png')
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
                    : const AssetImage('lib/assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            title: const Text('Blah blah'),
            subtitle: const Text('Hey there! I am using WhatsApp'),
            trailing: const Icon(Icons.qr_code),
          ),
          Divider(color: Colors.grey[800]),
          const SettingsListTile(
              icon: Icons.key,
              title: 'Account',
              subtitle: 'Privacy, security, change number'),
          const SettingsListTile(
              icon: Icons.chat,
              title: 'Chats',
              subtitle: 'Theme, wallpapers, chat history'),
          const SettingsListTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Message, group & call tones'),
          const SettingsListTile(
              icon: Icons.data_usage,
              title: 'Storage and data',
              subtitle: 'Network usage, auto-download'),
          const SettingsListTile(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Help centre, contact us, privacy policy'),
          const SettingsListTile(
              icon: Icons.group_add, title: 'Invite a friend', subtitle: ''),
        ],
      ),
    );
  }
}
