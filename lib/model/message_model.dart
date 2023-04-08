import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? sendBy;
  bool? seen;
  String? message;
  FieldValue? createdOn;

  MessageModel({required this.sendBy, required this.message, this.createdOn});
  MessageModel.fromJson(Map<String, dynamic> json) {
    sendBy = json["sendBy"];
    seen = json["seen"];
    message = json["message"];
    createdOn = json["createdOn"];
  }

  Map<String, dynamic> toJson() {
    return {
      "sendBy": sendBy,
      "seen": seen,
      "message": message,
      "createdOn": createdOn,
    };
  }
}
