class MessageModel {
  String? sender;
  bool? seen;
  String? text;
  DateTime? createdOn;

  MessageModel({this.sender, this.text, this.createdOn});
  MessageModel.fromJson(Map<String, dynamic> json) {
    sender = json["sender"];
    seen = json["seen"];
    text = json["text"];
    createdOn = json["createdOn"].toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "seen": seen,
      "text": text,
      "createdOn": createdOn,
    };
  }
}
