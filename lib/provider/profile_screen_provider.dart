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
      log("get data function started");
      notifyListeners();
    } catch (e) {
      showSimpleNotification(Text(e.toString()));
    }
    notifyListeners();
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

  isChecking(String uid) async {
    try {
      var currentUserData = FirebaseAuth.instance.currentUser;
      snapFollow =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      List followingList = (snapFollow!.data() as dynamic)["followers"];
      if (followingList.contains(currentUserData!.uid)) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
      notifyListeners();
    } catch (e) {
      // showSimpleNotification(Text(e.toString()));
      log(e.toString());
    }
  }
}
