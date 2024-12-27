import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget
{
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback?onTap;

  const SettingsListTile({super.key, required this.icon, required this.title, required this.subtitle, this.onTap,});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color,),
      title: Text(title, style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}