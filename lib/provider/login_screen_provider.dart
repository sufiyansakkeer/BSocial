import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreenProvider extends ChangeNotifier {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
}
