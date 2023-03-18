import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthMethods _authMethods = AuthMethods();
  UserModel get getUser => _user!;
  Future<void> refreshUser() async {}
  String userName = "";

  void getUserName() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    log(snap.data().toString());
    //* here we are username from the data as map ,
    //* using "as" we are converting the data object to map object
    userName = (snap.data() as Map<String, dynamic>)["username"];
  }

  void refreshUi() async {
    UserModel userModel = await _authMethods.getUserDetails();
    _user = userModel;
    notifyListeners();
  }
}
