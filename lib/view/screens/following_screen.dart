import 'package:bsocial/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key, required this.userUid});
  final String userUid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          "Following",
        ),
        centerTitle: true,
      ),
      // body: FutureBuilder(
      //   future: FirebaseFirestore.instance.collection("users").doc(uid).,

      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     return Container();
      //   },
      // ),
    );
  }
}
