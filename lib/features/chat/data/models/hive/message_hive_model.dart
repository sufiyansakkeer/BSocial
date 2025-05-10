import 'package:hive/hive.dart';
import '../../../domain/entities/message.dart';

part 'message_hive_model.g.dart';

/// Hive model for [Message] entity
@HiveType(typeId: 4)
class MessageHiveModel extends HiveObject {
  /// Constructor
  MessageHiveModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.roomId,
    required this.lastUpdated,
  });

  /// Convert from domain entity to Hive model
  factory MessageHiveModel.fromEntity(Message message) => MessageHiveModel(
        messageId: message.messageId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
        roomId: message.roomId,
        lastUpdated: DateTime.now(),
      );
      
  /// Message ID
  @HiveField(0)
  final String messageId;

  /// User ID of the sender
  @HiveField(1)
  final String senderId;

  /// User ID of the receiver
  @HiveField(2)
  final String receiverId;

  /// Message content
  @HiveField(3)
  final String content;

  /// Timestamp when the message was sent
  @HiveField(4)
  final DateTime timestamp;

  /// Whether the message has been read
  @HiveField(5)
  final bool isRead;

  /// Chat room ID
  @HiveField(6)
  final String roomId;

  /// When the message was last updated in local storage
  @HiveField(7)
  final DateTime lastUpdated;

  /// Convert to domain entity
  Message toEntity() => Message(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: timestamp,
        isRead: isRead,
        roomId: roomId,
      );
}
