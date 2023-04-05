import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FollowerProvider extends ChangeNotifier {
  var userData = {};
  List followers = [];
  List<UserModel>? userModelList;
  getUserFollowers({required String userUid}) async {
    userModelList = [];
    log("get user followers function started");
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .get();

      var fullSnap = await FirebaseFirestore.instance.collection("users").get();
      userData = userSnap.data()!;
      followers = userSnap.data()!["followers"];
      log("${followers.length} followers");
      for (var uid in followers) {
        for (var element in fullSnap.docs) {
          if (uid == element.data()["uid"]) {
            log("inside if");
            userModelList!.add(
              UserModel(
                email: element["email"],
                uid: uid,
                photoUrl: element["photoUrl"],
                userName: element["username"],
                followers: element["followers"],
                following: element["following"],
              ),
            );
            break;
          }
        }
      }
      log(userModelList!.length.toString());
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }
}
