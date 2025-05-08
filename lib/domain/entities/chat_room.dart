// ChatRoom entity class
class ChatRoom {
  const ChatRoom({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
  });
  final String roomId;
  final List<String> participants;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastMessageSenderId;
}
