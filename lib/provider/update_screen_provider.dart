import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../resources/storage_methods.dart';
import '../utils/utils.dart';

class UpdateScreenProvider extends ChangeNotifier {
  User currentUser = FirebaseAuth.instance.currentUser!;
  TextEditingController userNameController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;
  var userData = {};
  void selectImage() async {
    image = await pickedFile(ImageSource.gallery);
    notifyListeners();
  }

  getData() async {
    var currentUserDetails = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get();
    log("get data function started");
    userData = currentUserDetails.data()!;
    userNameController.text = userData["username"];
    image = assignImage(userData["photoUrl"]);
  }

  assignImage(String tempImg) async {
    log("$tempImg");
    final ByteData bytes = await rootBundle.load(tempImg);
    image = bytes.buffer.asUint8List();
    notifyListeners();
  }

  upDateFunction({required Uint8List image, required String username}) async {
    isLoading = true;
    String photoUrl =
        await StorageMethods().uploadImages('profilePics', image, false);
    final db = FirebaseFirestore.instance.batch();
    final ref =
        FirebaseFirestore.instance.collection("users").doc(currentUser.uid);
    db.update(ref, {"photoUrl": photoUrl});
    db.update(ref, {"username": username});
    await db.commit();
    isLoading = false;
  }
}
