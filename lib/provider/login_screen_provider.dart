import 'dart:developer';

import 'package:bsocial/core/utils.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  bool isLoading = false;
  loginUser(BuildContext context) async {
    isLoading = true;
    String res = await AuthMethods().loginUser(
      email: emailTextController.text,
      password: passwordTextController.text,
    );
    if (res == "success") {
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
}
