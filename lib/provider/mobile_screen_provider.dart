import 'package:bsocial/view/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MobileScreenProvider extends ChangeNotifier {
  final pages = [
    const HomeScreen(),
    const Settings(),
  ];
}
