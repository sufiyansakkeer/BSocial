import 'package:hive/hive.dart';
import '../../../domain/entities/chat_room.dart';

part 'chat_room_hive_model.g.dart';

/// Hive model for [ChatRoom] entity
@HiveType(typeId: 3)
class ChatRoomHiveModel extends HiveObject {
  /// Constructor
  ChatRoomHiveModel({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastUpdated,
  });

  /// Convert from domain entity to Hive model
  factory ChatRoomHiveModel.fromEntity(ChatRoom chatRoom) => ChatRoomHiveModel(
        roomId: chatRoom.roomId,
        participants: chatRoom.participants,
        lastMessageTime: chatRoom.lastMessageTime,
        lastMessage: chatRoom.lastMessage,
        lastMessageSenderId: chatRoom.lastMessageSenderId,
        lastUpdated: DateTime.now(),
      );
      
  /// Chat room ID
  @HiveField(0)
  final String roomId;

  /// List of participant user IDs
  @HiveField(1)
  final List<String> participants;

  /// Timestamp of the last message
  @HiveField(2)
  final DateTime lastMessageTime;

  /// Content of the last message
  @HiveField(3)
  final String lastMessage;

  /// User ID of the sender of the last message
  @HiveField(4)
  final String lastMessageSenderId;

  /// When the chat room was last updated in local storage
  @HiveField(5)
  final DateTime lastUpdated;

  /// Convert to domain entity
  ChatRoom toEntity() => ChatRoom(
        roomId: roomId,
        participants: participants,
        lastMessageTime: lastMessageTime,
        lastMessage: lastMessage,
        lastMessageSenderId: lastMessageSenderId,
      );
}
