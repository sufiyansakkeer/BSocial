import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ProfileScreenProvider extends ChangeNotifier {
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  DocumentSnapshot? snapFollow;
  Future<void> getData(String uid) async {
    try {
      log("Getting data for user: $uid");

      // Get user document
      var userSnap =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!userSnap.exists || userSnap.data() == null) {
        log("User document doesn't exist or is empty");
        showSimpleNotification(const Text("User profile not found"));
        return;
      }

      userData = userSnap.data()!;

      // Get posts
      var postSnap = await FirebaseFirestore.instance
          .collection("posts")
          .where("uid", isEqualTo: uid)
          .get();

      postLength = postSnap.docs.length;

      // Safely access followers and following with null checks
      followers =
          userData["followers"] != null ? userData["followers"].length : 0;
      following =
          userData["following"] != null ? userData["following"].length : 0;

      log("Profile data loaded successfully");
      notifyListeners();
    } catch (e) {
      log("Error loading profile data: ${e.toString()}");
      showSimpleNotification(Text("Error loading profile: ${e.toString()}"));
    }
  }

  set isFollowin(bool value) {
    isFollowing = value;
    notifyListeners();
  }

  isFollowFunctionInc() {
    isFollowing = true;
    followers++;
    notifyListeners();
  }

  isFollowingDec() {
    isFollowing = false;
    followers--;
    notifyListeners();
  }

  Future<void> isChecking(String uid) async {
    try {
      var currentUserData = FirebaseAuth.instance.currentUser;
      if (currentUserData == null) {
        log("Current user is null in isChecking");
        isFollowing = false;
        notifyListeners();
        return;
      }

      snapFollow =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!snapFollow!.exists || snapFollow!.data() == null) {
        log("User document doesn't exist or is empty in isChecking");
        isFollowing = false;
        notifyListeners();
        return;
      }

      final userData = snapFollow!.data() as Map<String, dynamic>;

      if (!userData.containsKey("followers")) {
        log("Followers field doesn't exist in user document");
        isFollowing = false;
        notifyListeners();
        return;
      }

      List followingList = userData["followers"];
      isFollowing = followingList.contains(currentUserData.uid);

      notifyListeners();
    } catch (e) {
      log("Error in isChecking: ${e.toString()}");
      isFollowing = false;
      notifyListeners();
    }
  }
}
