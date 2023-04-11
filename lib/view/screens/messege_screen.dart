import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/message_screen_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
import 'package:bsocial/view/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({
    super.key,
    required this.chatRoomId,
    required this.targetUser,
    // required this.targetUser, required this.chatRoomModel,
  });
  final String chatRoomId;
  final UserModel targetUser;
  // final UserModel currentUserModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    log(chatRoomId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFA150C7),
              backgroundImage: NetworkImage(
                targetUser.photoUrl,
              ),
            ),
            kWidth,
            Column(
              children: [
                Text(
                  targetUser.userName,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(targetUser.uid)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "offline",
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Text(
                          "offline",
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return Text(
                      snapshot.data["status"],
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection("chatRoom")
                  .doc(chatRoomId)
                  .collection("chats")
                  .orderBy("createdOn", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  log("snapshot has no data");
                  return Container();
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Check your Internet connection"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data.docs[index].data();
                    return message(map: map, context: context);
                  },
                  itemCount: snapshot.data.docs.length,
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child:
                    Consumer<MessageProvider>(builder: (context, value, child) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextFormField(
                      controller: value.messageController,
                      decoration: const InputDecoration(
                        hintText: "  Message",
                      ),
                    ),
                  );
                }),
              ),
              Consumer<MessageProvider>(builder: (context, value, child) {
                return IconButton(
                  onPressed: () {
                    value.onSentFunction(
                        userUid: targetUser.uid, chatRoomId: chatRoomId);
                  },
                  icon: const Icon(
                    Icons.send,
                  ),
                );
              }),
            ],
          )
        ],
      ),
    );
  }
}
