import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Views/View.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends GetView {
  @override
  Widget build(BuildContext context)
  {
    return GetMaterialApp(
      title: 'Flutter GetX Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}