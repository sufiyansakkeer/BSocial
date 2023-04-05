import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
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
    image = await assignImage(userData["photoUrl"]);
    notifyListeners();
    // log(image.toString());
  }

  Future<Uint8List> assignImage(String tempImg) async {
    // final ByteData bytes = await rootBundle.load(tempImg);
    Response response = await get(Uri.parse(tempImg));
    log(response.statusCode.toString());
    log(response.bodyBytes.length.toString());
    return response.bodyBytes.buffer.asUint8List();
    // log('bytes: ${bytes.lengthInBytes}');
    // image = bytes.buffer.asUint8List();
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
