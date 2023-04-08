import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget message(
    {required Map<String, dynamic> map, required BuildContext context}) {
  return Container(
    width: MediaQuery.of(context).size.width * 5,
    alignment: map["sendBy"] == FirebaseAuth.instance.currentUser!.uid
        ? Alignment.centerLeft
        : Alignment.centerRight,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.blue),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(map["message"]),
    ),
  );
}
