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
    try {
      var currentUserDetails = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      log("get data function started");

      if (currentUserDetails.exists && currentUserDetails.data() != null) {
        userData = currentUserDetails.data()!;
        userNameController.text = userData["username"] ?? "";

        if (userData["photoUrl"] != null) {
          image = await assignImage(userData["photoUrl"]);
        } else {
          // Load a default image from assets if no profile image exists
          image = await loadDefaultImage();
        }
      } else {
        log("User document doesn't exist or is empty");
        // Load default image and empty username
        image = await loadDefaultImage();
        userNameController.text = "";
      }

      notifyListeners();
    } catch (e) {
      log("Error in getData: ${e.toString()}");
      // Load default image on error
      image = await loadDefaultImage();
      notifyListeners();
    }
  }

  Future<Uint8List> assignImage(String tempImg) async {
    try {
      Response response = await get(Uri.parse(tempImg));
      log("Image response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("Image bytes length: ${response.bodyBytes.length}");
        return response.bodyBytes.buffer.asUint8List();
      } else {
        log("Failed to load image, status code: ${response.statusCode}");
        return await loadDefaultImage();
      }
    } catch (e) {
      log("Error loading image: ${e.toString()}");
      return await loadDefaultImage();
    }
  }

  Future<Uint8List> loadDefaultImage() async {
    try {
      // Load a default image from assets
      final ByteData bytes = await rootBundle.load('assets/images/images.jpeg');
      return bytes.buffer.asUint8List();
    } catch (e) {
      log("Error loading default image: ${e.toString()}");
      // Create a simple colored image as fallback
      return createPlaceholderImage();
    }
  }

  Uint8List createPlaceholderImage() {
    // Create a simple 100x100 blue image as a last resort
    final int width = 100;
    final int height = 100;
    final int bytesPerPixel = 4; // RGBA

    final Uint8List pixels = Uint8List(width * height * bytesPerPixel);

    // Fill with a blue color (RGBA)
    for (int i = 0; i < pixels.length; i += bytesPerPixel) {
      pixels[i] = 0; // R
      pixels[i + 1] = 0; // G
      pixels[i + 2] = 255; // B
      pixels[i + 3] = 255; // A (opacity)
    }

    return pixels;
  }

  Future<void> upDateFunction(
      {required Uint8List image, required String username}) async {
    try {
      isLoading = true;
      notifyListeners();

      // Validate inputs
      if (username.trim().isEmpty) {
        throw Exception("Username cannot be empty");
      }

      // Upload image to Firebase Storage
      String photoUrl =
          await StorageMethods().uploadImages('profilePics', image, false);

      // Update Firestore document
      final db = FirebaseFirestore.instance.batch();
      final ref =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);
      db.update(ref, {"photoUrl": photoUrl});
      db.update(ref, {"username": username});
      await db.commit();

      log("Profile updated successfully");
    } catch (e) {
      log("Error updating profile: ${e.toString()}");
      rethrow; // Re-throw to handle in UI
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
