import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';

abstract class ChatRemoteDataSource {
  // Get all chat rooms for a user
  Future<List<ChatRoomModel>> getChatRooms(String userId);

  // Create a new chat room
  Future<ChatRoomModel> createChatRoom(List<String> participants);

  // Get a chat room by ID
  Future<ChatRoomModel> getChatRoomById(String roomId);

  // Get a chat room by participants
  Future<ChatRoomModel?> getChatRoomByParticipants(List<String> participants);

  // Send a message
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  });

  // Get messages for a chat room
  Future<List<MessageModel>> getMessages(String roomId);

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId);

  // Delete a message
  Future<void> deleteMessage(String messageId, String roomId);

  // Delete a chat room
  Future<void> deleteChatRoom(String roomId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  final FirebaseFirestore _firestore;

  @override
  Future<ChatRoomModel> createChatRoom(List<String> participants) async {
    try {
      // Check if a chat room already exists with these participants
      final existingRoom = await getChatRoomByParticipants(participants);
      if (existingRoom != null) {
        return existingRoom;
      }

      // Generate a unique room ID
      final roomId = const Uuid().v1();
      final now = DateTime.now();

      // Create chat room model
      final chatRoom = ChatRoomModel(
        roomId: roomId,
        participants: participants,
        lastMessageTime: now,
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
      log('Error creating chat room: $e');
      throw ServerException(
          message: 'Failed to create chat room: ${e.toString()}');
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

      // Delete the chat room document
      batch.delete(
          _firestore.collection(AppConstants.chatsCollection).doc(roomId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      log('Error deleting chat room: $e');
      throw ServerException(
          message: 'Failed to delete chat room: ${e.toString()}');
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
      log('Error deleting message: $e');
      throw ServerException(
          message: 'Failed to delete message: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomModel> getChatRoomById(String roomId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .get();

      if (!docSnapshot.exists) {
        throw ServerException(message: 'Chat room not found');
      }

      return ChatRoomModel.fromSnapshot(docSnapshot);
    } catch (e) {
      log('Error getting chat room: $e');
      throw ServerException(
          message: 'Failed to get chat room: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomModel?> getChatRoomByParticipants(
      List<String> participants) async {
    try {
      // Sort participants to ensure consistent ordering
      final sortedParticipants = [...participants]..sort();

      // Query for chat rooms containing all participants
      final querySnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', arrayContainsAny: sortedParticipants)
          .get();

      // Filter to find a room with exactly these participants
      for (final doc in querySnapshot.docs) {
        final room = ChatRoomModel.fromSnapshot(doc);
        final roomParticipants = [...room.participants]..sort();

        if (roomParticipants.length == sortedParticipants.length &&
            roomParticipants.every(sortedParticipants.contains)) {
          return room;
        }
      }

      return null;
    } catch (e) {
      log('Error getting chat room by participants: $e');
      throw ServerException(
          message: 'Failed to get chat room: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      // First try with the compound query (requires index)
      try {
        final querySnapshot = await _firestore
            .collection(AppConstants.chatsCollection)
            .where('participants', arrayContains: userId)
            .orderBy('lastMessageTime', descending: true)
            .get();

        return querySnapshot.docs.map(ChatRoomModel.fromSnapshot).toList();
      } catch (indexError) {
        // If index error occurs, use a fallback approach
        log('Index error, using fallback approach: $indexError');

        // Fallback: Get all chat rooms for the user without ordering
        final querySnapshot = await _firestore
            .collection(AppConstants.chatsCollection)
            .where('participants', arrayContains: userId)
            .get();

        // Convert to models and sort in memory
        final chatRooms =
            querySnapshot.docs.map(ChatRoomModel.fromSnapshot).toList();

        // Sort by lastMessageTime in descending order
        chatRooms
            .sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

        return chatRooms;
      }
    } catch (e) {
      log('Error getting chat rooms: $e');
      throw ServerException(
          message: 'Failed to get chat rooms: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String roomId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map(MessageModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting messages: $e');
      throw ServerException(message: 'Failed to get messages: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      log('Error marking messages as read: $e');
      throw ServerException(
          message: 'Failed to mark messages as read: ${e.toString()}');
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
      final now = DateTime.now();

      // Create message model
      final message = MessageModel(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: now,
        isRead: false,
      );

      // Save message to Firestore
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .set(message.toJson());

      // Update the chat room with the last message
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .update({
        'lastMessage': content,
        'lastMessageTime': now,
        'lastMessageSenderId': senderId,
      });

      return message;
    } catch (e) {
      log('Error sending message: $e');
      throw ServerException(message: 'Failed to send message: ${e.toString()}');
    }
  }
}
