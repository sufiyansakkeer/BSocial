class ChatRoomModel {
  String? chatRoomId;
  List<String>? participants;
  ChatRoomModel({this.chatRoomId, this.participants});
  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    chatRoomId = json["chatRoomId"];
    participants = json["participants"];
  }

  Map<String, dynamic> toJson() {
    return {
      "chatRoomId": chatRoomId,
      "participants": participants,
    };
  }
}
