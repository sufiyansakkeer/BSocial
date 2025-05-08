// ChatRoom entity class
class ChatRoom {
  final String roomId;
  final List<String> participants;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastMessageSenderId;
  
  const ChatRoom({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
  });
}
