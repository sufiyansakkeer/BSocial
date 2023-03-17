import 'dart:developer';
import 'dart:typed_data';

import 'package:bsocial/core/utils.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;
  // BuildContext? context;
  void selectImage() async {
    image = await pickedFile(ImageSource.gallery);
    notifyListeners();
  }

  signUpUser(BuildContext context) async {
    String res = await AuthMethods().signUpUser(
      username: userNameController.text,
      email: emailTextController.text,
      password: passwordTextController.text,
      file: image!,
    );
    isLoading = true;

    if (res != "success") {
      showSnackBar(res, context);
    }
    log(res);
  }
}
