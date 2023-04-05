import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingProvider extends ChangeNotifier {
  List<UserModel>? userModelList;
  bool isLoading = false;
  getAllFollowing(String userUid) async {
    log('following function started');
    userModelList = [];
    try {
      isLoading = true;
      var userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .get();
      var currentUserData = userSnap.data();
      List following = currentUserData!["following"];
      log(following.length.toString());
      var fullSnap = await FirebaseFirestore.instance.collection("users").get();
      for (var uid in following) {
        for (var element in fullSnap.docs) {
          if (uid == element.data()["uid"]) {
            userModelList!.add(
              UserModel(
                email: element.data()["email"],
                uid: uid,
                photoUrl: element.data()["photoUrl"],
                userName: element.data()["username"],
                followers: element.data()["followers"],
                following: element.data()["following"],
              ),
            );
            break;
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }
}
