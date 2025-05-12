import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/message.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';
import 'chat_remote_data_source.dart';

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
      log('Error getting chat rooms: $e', name: 'getChatRooms');
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
      log('Error creating chat room: $e', name: 'createChatRoom');
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
      log('Error getting chat room: $e', name: 'getChatRoomById');
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
      log('Error getting chat room by participants: $e',
          name: 'getChatRoomByParticipants');
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
      final now = DateTime.now();

      // Create message model with sent status
      final message = MessageModel(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: now,
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
      log('Error sending message: $e', name: 'sendMessage');
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
      log('Error getting messages: $e', name: 'getMessages');
      throw ServerException(message: 'Failed to get messages: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessagesPaginated(
    String roomId, {
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      var query = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map(MessageModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting paginated messages: $e', name: 'getMessagesPaginated');
      throw ServerException(message: 'Failed to get paginated messages: $e');
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
        batch.update(
          doc.reference,
          {'isRead': true, 'status': MessageStatus.read.index},
        );
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      log('Error marking messages as read: $e', name: 'markMessagesAsRead');
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
      log('Error deleting message: $e', name: 'deleteMessage');
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
      log('Error deleting chat room: $e', name: 'deleteChatRoom');
      throw ServerException(message: 'Failed to delete chat room: $e');
    }
  }
}
