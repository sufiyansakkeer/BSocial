import 'dart:developer';

import 'package:bsocial/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();

  onSentFunction({required String userUid, required String chatRoomId}) async {
    if (messageController.text.isNotEmpty) {
      MessageModel messageModel = MessageModel(
          sendBy: userUid,
          message: messageController.text,
          createdOn: FieldValue.serverTimestamp(),
          seen: false);

      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chats")
          .add(messageModel.toJson());
      messageController.clear();
    } else {
      log('Enter some message');
    }
  }
}
