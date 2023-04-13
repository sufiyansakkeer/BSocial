import 'dart:developer';

import 'package:bsocial/model/message_model.dart';
import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/message_screen_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
import 'package:bsocial/view/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

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
                  .orderBy("createdOn", descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                var _auth = FirebaseAuth.instance.currentUser;
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
                // return GroupedListView(
                //   elements: snapshot.data.docs,
                //   groupBy: (element) => snapshot.data.docs["createdOn"],
                //   groupSeparatorBuilder: (value) => Container(
                //     child: Text(value),
                //   ),
                //   itemBuilder: (context, element) => Card(
                //     child: ListTile(
                //       title: Text("skjkj"),
                //     ),
                //   ),
                // );
                List<MessageModelTwo> messageList = [];
                for (var element in snapshot.data.docs) {
                  log("for loop is working ${element['message']}",
                      name: "for in Loop ");

                  DateTime currentDate = DateTime.now();
                  DateTime date = element['createdOn'] == null
                      ? currentDate
                      : (element['createdOn'] as Timestamp).toDate();
                  messageList.add(MessageModelTwo(
                      sendBy: element["sendBy"],
                      message: element["message"],
                      createdOn: date,
                      seen: element["seen"]));
                  // messageList.add(element);
                  // messageList.add(
                  //     MessageModel.fromJson(element as _JsonQueryDocumentSnapshot));
                }
                log("success");
                //List<MessageModel> messageList = snapshot.data.docs.data();
                log(messageList.length.toString(), name: "messageListLength");
                return ListView.builder(
                  reverse: true,
                  itemBuilder: (context, index) {
                    // Map<String, dynamic> map = snapshot.data.docs[index].data();
                    String previousDate;
                    if (index < snapshot.data.docs.length - 1) {
                      // log("$index ${map['message']}");
                      previousDate = DateFormat.yMMMMEEEEd()
                          .format(messageList[index + 1].createdOn!);
                    } else {
                      // log(" else rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr  $index $map['message'] ${snapshot.data.docs.length - 1}");
                      previousDate = "";
                    }

                    String date = DateFormat.yMMMMEEEEd()
                        .format(messageList[index].createdOn!);
                    //log("${index} ${map['message']} ${snapshot.data.docs.length - 1}");
                    return previousDate != date
                        ? dateDivider(messageList[index], _auth!.uid, context)
                        : message(map: messageList[index], context: context);
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

StickyHeaderBuilder dateDivider(
    MessageModelTwo state, String currentUser, BuildContext context) {
  return StickyHeaderBuilder(
    builder: (context, stuckAmount) {
      String dateOfChat = state.createdOn.toString();
      DateTime convertedDate = state.createdOn!;
      log("${convertedDate.toString()} is the date");
      if (convertedDate.day == DateTime.now().day &&
          convertedDate.month == DateTime.now().month &&
          convertedDate.year == DateTime.now().year) {
        dateOfChat = "Today";
      } else if (convertedDate.day == DateTime.now().day - 1 &&
          convertedDate.month == DateTime.now().month &&
          convertedDate.year == DateTime.now().year) {
        dateOfChat = "Yesterday";
      } else {
        dateOfChat = DateFormat.yMMMMEEEEd().format(convertedDate);
      }

      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            dateOfChat,
          ),
        ),
      );
    },
    content: message(map: state, context: context),
    // content: message(
    //   message: state,
    //   uID: currentUser,
    // ),
  );
}
