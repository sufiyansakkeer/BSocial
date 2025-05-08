import 'package:hive/hive.dart';
import '../../../domain/entities/chat_room.dart';

part 'chat_room_hive_model.g.dart';

@HiveType(typeId: 3)
class ChatRoomHiveModel extends HiveObject {
  ChatRoomHiveModel({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastUpdated,
  });

  // Convert from domain entity to Hive model
  factory ChatRoomHiveModel.fromEntity(ChatRoom chatRoom) => ChatRoomHiveModel(
        roomId: chatRoom.roomId,
        participants: chatRoom.participants,
        lastMessageTime: chatRoom.lastMessageTime,
        lastMessage: chatRoom.lastMessage,
        lastMessageSenderId: chatRoom.lastMessageSenderId,
        lastUpdated: DateTime.now(),
      );
  @HiveField(0)
  final String roomId;

  @HiveField(1)
  final List<String> participants;

  @HiveField(2)
  final DateTime lastMessageTime;

  @HiveField(3)
  final String lastMessage;

  @HiveField(4)
  final String lastMessageSenderId;

  @HiveField(5)
  final DateTime lastUpdated;

  // Convert to domain entity
  ChatRoom toEntity() => ChatRoom(
        roomId: roomId,
        participants: participants,
        lastMessageTime: lastMessageTime,
        lastMessage: lastMessage,
        lastMessageSenderId: lastMessageSenderId,
      );
}
