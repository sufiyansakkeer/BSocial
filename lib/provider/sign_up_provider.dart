import 'dart:typed_data';

import 'package:bsocial/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  Uint8List? image;

  void selectImage() async {
    image = await pickedFile(ImageSource.gallery);
    notifyListeners();
  }
}
