import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.help), // Ikon untuk Help Center
            title: Text('Help Center'),
          ),
          ListTile(
            leading: Icon(Icons.contact_support), // Ikon untuk Contact Us
            title: Text('Contact Us'),
          ),
        ],
      ),
    );
  }
}
