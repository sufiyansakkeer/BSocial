import 'package:hive/hive.dart';
import '../../../domain/entities/message.dart';

part 'message_hive_model.g.dart';

@HiveType(typeId: 4)
class MessageHiveModel extends HiveObject {
  MessageHiveModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.lastUpdated,
  });

  // Convert from domain entity to Hive model
  factory MessageHiveModel.fromEntity(Message message) => MessageHiveModel(
        messageId: message.messageId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
        lastUpdated: DateTime.now(),
      );
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final DateTime lastUpdated;

  // Convert to domain entity
  Message toEntity() => Message(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: timestamp,
        isRead: isRead,
      );
}
