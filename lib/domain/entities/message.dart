// Message entity class
class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String roomId; // Added for Hive implementation

  const Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.roomId = '', // Default empty string for backward compatibility
  });
}
