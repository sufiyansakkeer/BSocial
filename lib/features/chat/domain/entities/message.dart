/// Enum for message status
enum MessageStatus {
  /// Message is being sent
  sending,

  /// Message has been sent to the server
  sent,

  /// Message has been delivered to the recipient
  delivered,

  /// Message has been read by the recipient
  read,

  /// Message failed to send
  failed,
}

/// Message entity class
class Message {
  /// Constructor
  const Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.roomId = '', // Default empty string for backward compatibility
    this.status = MessageStatus.sent,
  });

  /// Message ID
  final String messageId;

  /// User ID of the sender
  final String senderId;

  /// User ID of the receiver
  final String receiverId;

  /// Message content
  final String content;

  /// Timestamp when the message was sent
  final DateTime timestamp;

  /// Whether the message has been read
  final bool isRead;

  /// Chat room ID
  final String roomId;

  /// Message status
  final MessageStatus status;

  /// Create a copy of this message with the given fields replaced
  /// with the new values
  Message copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? roomId,
    MessageStatus? status,
  }) =>
      Message(
        messageId: messageId ?? this.messageId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        roomId: roomId ?? this.roomId,
        status: status ?? this.status,
      );
}
