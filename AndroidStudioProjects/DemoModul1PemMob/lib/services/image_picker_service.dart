import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService
{
  final ImagePicker _picker = ImagePicker();

  File? _profilePictures;

  File? get profilePicture => _profilePictures;

  void pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if(pickedFile != null)
      {
        _profilePictures = pickedFile as File;
      }
  }
}