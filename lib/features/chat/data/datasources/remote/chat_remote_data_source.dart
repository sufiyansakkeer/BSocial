import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';

/// Interface for chat remote data source
abstract class ChatRemoteDataSource {
  /// Get all chat rooms for a user
  Future<List<ChatRoomModel>> getChatRooms(String userId);

  /// Create a new chat room
  Future<ChatRoomModel> createChatRoom(List<String> participants);

  /// Get a chat room by ID
  Future<ChatRoomModel> getChatRoomById(String roomId);

  /// Get a chat room by participants
  Future<ChatRoomModel?> getChatRoomByParticipants(List<String> participants);

  /// Send a message
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  });

  /// Get messages for a chat room
  Future<List<MessageModel>> getMessages(String roomId);

  /// Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId);

  /// Delete a message
  Future<void> deleteMessage(String messageId, String roomId);

  /// Delete a chat room
  Future<void> deleteChatRoom(String roomId);
}

/// Implementation of [ChatRemoteDataSource]
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  /// Constructor
  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs.map(ChatRoomModel.fromSnapshot).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get chat rooms: $e');
    }
  }

  @override
  Future<ChatRoomModel> createChatRoom(List<String> participants) async {
    try {
      // First, check if a chat room already exists with these participants
      final existingRoom = await getChatRoomByParticipants(participants);
      if (existingRoom != null) {
        return existingRoom;
      }

      // Sort participants to ensure consistent order
      final sortedParticipants = [...participants]..sort();

      // Generate a deterministic room ID based on participants
      // This ensures only one chat room exists between any two users
      final roomId = sortedParticipants.join('_');

      // Create chat room model
      final chatRoom = ChatRoomModel(
        roomId: roomId,
        participants:
            sortedParticipants, // Use sorted participants for consistency
        lastMessageTime: DateTime.now(),
        lastMessage: '',
        lastMessageSenderId: '',
      );

      // Save chat room to Firestore
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .set(chatRoom.toJson());

      return chatRoom;
    } catch (e) {
      throw ServerException(message: 'Failed to create chat room: $e');
    }
  }

  @override
  Future<ChatRoomModel> getChatRoomById(String roomId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .get();

      if (!snapshot.exists) {
        throw ServerException(message: 'Chat room not found');
      }

      return ChatRoomModel.fromSnapshot(snapshot);
    } catch (e) {
      throw ServerException(message: 'Failed to get chat room: $e');
    }
  }

  @override
  Future<ChatRoomModel?> getChatRoomByParticipants(
      List<String> participants) async {
    try {
      // Sort participants to ensure consistent order
      final sortedParticipants = [...participants]..sort();

      // Generate the deterministic room ID
      final roomId = sortedParticipants.join('_');

      // Try to get the chat room directly by its ID
      final docSnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .get();

      if (docSnapshot.exists) {
        return ChatRoomModel.fromSnapshot(docSnapshot);
      }

      // As a fallback, query for chat rooms with exactly these participants
      // This is useful for backward compatibility with existing chat rooms
      final querySnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', isEqualTo: sortedParticipants)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ChatRoomModel.fromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      throw ServerException(
          message: 'Failed to get chat room by participants: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Generate a unique message ID
      final messageId = const Uuid().v1();

      // Create message model
      final message = MessageModel(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        roomId: roomId,
      );

      // Save message to Firestore
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .set(message.toJson());

      // Update chat room with last message info
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .update({
        'lastMessage': content,
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': senderId,
      });

      return message;
    } catch (e) {
      throw ServerException(message: 'Failed to send message: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String roomId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map(MessageModel.fromSnapshot).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get messages: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      // Get unread messages sent to this user
      final snapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Create a batch to update all messages at once
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId, String roomId) async {
    try {
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete message: $e');
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      // Delete all messages in the chat room
      final messagesSnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .get();

      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat room
      batch.delete(
          _firestore.collection(AppConstants.chatsCollection).doc(roomId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to delete chat room: $e');
    }
  }
}
