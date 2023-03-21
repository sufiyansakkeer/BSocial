import 'dart:developer';

import 'package:bsocial/utils/utils.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/responsive_layout_building.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:bsocial/view/screens/sign_up_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  bool isLoading = false;
  loginUser(BuildContext context) async {
    String res = await AuthMethods().loginUser(
      email: emailTextController.text,
      password: passwordTextController.text,
    );
    isLoading = true;
    if (context.mounted) {}
    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
      disposeTextfield(context);
    } else {
      showSnackBar(res, context);
    }
    isLoading = false;
    log(res);
  }

  void disposeTextfield(context) {
    final provider = Provider.of<LoginScreenProvider>(context, listen: false);
    provider.emailTextController.clear();
    provider.passwordTextController.clear();
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
    disposeTextfield(context);
  }
}
