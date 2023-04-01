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
  getData(String uid) async {
    try {
      var userSnap =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      userData = userSnap.data()!;
      //get post length
      var postSnap = await FirebaseFirestore.instance
          .collection("posts")
          .where("uid", isEqualTo: uid)
          .get();

      postLength = postSnap.docs.length;
      followers = userSnap.data()!["followers"].length;
      following = userSnap.data()!["following"].length;
      log("message");
      notifyListeners();
    } catch (e) {
      showSimpleNotification(Text(e.toString()));
    }
  }

  isFollowFunctionInc() {
    isFollowing = false;
    followers++;
    notifyListeners();
  }

  isFollowingDec() {
    isFollowing = true;
    followers--;
    notifyListeners();
  }
}
