import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      child: Column(
        children: [
          Text(map["message"]),
          Text(
            DateFormat.jm().format(
              DateTime.fromMicrosecondsSinceEpoch(
                  map["createdOn"].microsecondsSinceEpoch),
            ),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
