import 'package:demomodul1pemmob/app/views/logreg/Login_Screen.dart';
import 'package:flutter/material.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  _splashscreenState createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login_Screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2329),
      body: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/chat.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
