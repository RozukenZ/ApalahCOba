
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget
{
  final IconData icon;
  final String title;
  final String subtitle;

  SettingsListTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400]),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
    );
  }
}