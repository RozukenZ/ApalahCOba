import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Ambil Foto'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: _image != null
                    ? ClipOval(
                  child: Image.file(
                    _image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipOval(
                  child: Image.asset(
                    'assets/PP1.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 30, color: Colors.white);
                    },
                  ),
                ),
              ),
            ),
            title: Text('Blah blah'),
            subtitle: Text('Hey there! I am using WhatsApp'),
            trailing: Icon(Icons.qr_code),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.key),
            title: Text('Account'),
            subtitle: Text('Privacy, security, change number'),
          ),
          // ... (other ListTiles remain the same)
        ],
      ),
    );
  }
}