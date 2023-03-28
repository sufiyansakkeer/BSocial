import 'dart:developer';
import 'dart:typed_data';

import 'package:bsocial/utils/utils.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/responsive_layout_building.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:bsocial/view/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

class SignUpScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController passwordTextController2 = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;
  bool isPass1 = true;
  bool isPass2 = true;
  // BuildContext? context;
  // void selectImage() async {
  //   image = await pickedFile(ImageSource.gallery);
  //   notifyListeners();
  // }
  assignImage() async {
    final ByteData bytes = await rootBundle.load('assets/images/images.jpeg');
    image = bytes.buffer.asUint8List();
    notifyListeners();
  }

  signUpUser(BuildContext context) async {
    isLoading = true;
    bool flags = false;
    if (image == null) {
      await assignImage();
      flags = true;
    } else {
      image = image;
      flags = false;
    }
    log(flags.toString());
    String res = await AuthMethods().signUpUser(
      userName: userNameController.text,
      email: emailTextController.text,
      password: passwordTextController.text,
      file: image!,
    );
    // log("$res in signUp provider");
    if (context.mounted) {
      if (res != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              webScreenLayout: WebScreenLayout(),
              mobileScreenLayout: MobileScreenLayout(),
            ),
          ),
        );
        disposeTextfield(context);
        isLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
    isLoading = false;
    log(res);
  }

  void disposeTextfield(context) {
    final provider = Provider.of<SignUpScreenProvider>(context, listen: false);
    provider.emailTextController.clear();
    provider.passwordTextController.clear();
    provider.userNameController.clear();
    provider.passwordTextController2.clear();
  }

  void navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
    disposeTextfield(context);
  }

  bool passWordChecking() {
    if (passwordTextController.text == passwordTextController2.text) {
      return true;
    } else {
      return false;
    }
  }

  void showPassword1() {
    isPass1 = !isPass1;
    notifyListeners();
  }

  void showPassword2() {
    isPass2 = !isPass2;
    notifyListeners();
  }
}
