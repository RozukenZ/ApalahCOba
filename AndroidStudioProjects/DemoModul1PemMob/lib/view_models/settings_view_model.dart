import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SettingsViewModel extends GetxController
{
  final Rx<File?> _profilePicture = Rx<File?>(null);

  File? get profilePicture => _profilePicture.value;

  Future<void> pickImage(ImageSource source) async
  {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        _profilePicture.value = File(pickedFile.path);
      }
    } catch (e) {

      print('Error: $e');
    }
  }
}