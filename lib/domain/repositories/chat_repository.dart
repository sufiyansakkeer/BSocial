import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/typedefs.dart';
import '../entities/chat_room.dart';
import '../../features/chat/domain/entities/message.dart'; // Corrected import

// Chat repository interface
abstract class ChatRepository {
  // Get all chat rooms for a user
  ResultFuture<List<ChatRoom>> getChatRooms(String userId);

  // Create a new chat room
  ResultFuture<ChatRoom> createChatRoom(List<String> participants);

  // Get a chat room by ID
  ResultFuture<ChatRoom> getChatRoomById(String roomId);

  // Get a chat room by participants
  ResultFuture<ChatRoom?> getChatRoomByParticipants(List<String> participants);

  // Send a message
  ResultFuture<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  });

  // Get messages for a chat room
  ResultFuture<List<Message>> getMessages(
    String roomId, {
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  });

  // Mark messages as read
  ResultVoid markMessagesAsRead(String roomId, String userId);

  // Delete a message
  ResultVoid deleteMessage(String messageId, String roomId);

  // Delete a chat room
  ResultVoid deleteChatRoom(String roomId);
}
