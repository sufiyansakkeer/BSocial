import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

/// Model class for [Message] entity
class MessageModel extends Message {
  /// Constructor
  const MessageModel({
    required super.messageId,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.timestamp,
    required super.isRead,
    super.roomId = '',
    super.status = MessageStatus.sent,
  });

  /// Create model from Firestore snapshot
  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return MessageModel.fromJson(data);
  }

  /// Create model from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        messageId: json['messageId'] ?? '',
        senderId: json['senderId'] ?? '',
        receiverId: json['receiverId'] ?? '',
        content: json['content'] ?? '',
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        isRead: json['isRead'] ?? false,
        roomId: json['roomId'] ?? '',
        status: _parseStatus(json['status']),
      );

  /// Convert model to JSON
  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': timestamp,
        'isRead': isRead,
        'roomId': roomId,
        'status': status.index,
      };

  /// Parse status from JSON
  static MessageStatus _parseStatus(dynamic statusValue) {
    if (statusValue == null) {
      return MessageStatus.sent;
    }

    if (statusValue is int &&
        statusValue >= 0 &&
        statusValue < MessageStatus.values.length) {
      return MessageStatus.values[statusValue];
    }

    return MessageStatus.sent;
  }

  /// Convert model to entity
  Message toEntity(String? currentRoomId) => Message(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: timestamp,
        isRead: isRead,
        roomId: roomId.isNotEmpty ? roomId : currentRoomId ?? '',
        status: status,
      );
}
