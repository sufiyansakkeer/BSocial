import 'package:bsocial/model/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget message({required MessageModelTwo map, required BuildContext context}) {
  return Container(
    width: MediaQuery.of(context).size.width * 5,
    alignment: map.sendBy == FirebaseAuth.instance.currentUser!.uid
        ? Alignment.centerLeft
        : Alignment.centerRight,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.blue),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(map.message ?? ""),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat.jm().format(
                  map.createdOn!,
                ),
                style: const TextStyle(fontSize: 10),
              ),
              map.sendBy != FirebaseAuth.instance.currentUser!.uid
                  ? Icon(
                      Icons.done_all,
                      color: Colors.grey,
                    )
                  : Text(""),
            ],
          ),
        ],
      ),
    ),
  );
}
