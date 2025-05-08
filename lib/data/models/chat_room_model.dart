import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.roomId,
    required super.participants,
    required super.lastMessageTime,
    required super.lastMessage,
    required super.lastMessageSenderId,
  });

  // Create model from JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
        roomId: json['roomId'] ?? '',
        participants: _convertToStringList(json['participants'] ?? []),
        lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
        lastMessage: json['lastMessage'] ?? '',
        lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      );

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'participants': participants,
        'lastMessageTime': lastMessageTime,
        'lastMessage': lastMessage,
        'lastMessageSenderId': lastMessageSenderId,
      };

  // Create model from Firestore snapshot
  static ChatRoomModel fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatRoomModel.fromJson(data);
  }

  // Helper method to convert dynamic list to List<String>
  static List<String> _convertToStringList(List<dynamic> list) =>
      list.map((item) => item.toString()).toList();
}
