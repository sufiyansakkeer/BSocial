/// ChatRoom entity class
class ChatRoom {
  /// Constructor
  const ChatRoom({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
  });
  
  /// Chat room ID
  final String roomId;
  
  /// List of participant user IDs
  final List<String> participants;
  
  /// Timestamp of the last message
  final DateTime lastMessageTime;
  
  /// Content of the last message
  final String lastMessage;
  
  /// User ID of the sender of the last message
  final String lastMessageSenderId;
  
  /// Create a copy of this chat room with the given fields replaced
  /// with the new values
  ChatRoom copyWith({
    String? roomId,
    List<String>? participants,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? lastMessageSenderId,
  }) =>
      ChatRoom(
        roomId: roomId ?? this.roomId,
        participants: participants ?? this.participants,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      );
}
