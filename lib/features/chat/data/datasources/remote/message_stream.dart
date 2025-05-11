import 'package:bsocial/core/constants/app_constants.dart';
import 'package:bsocial/features/chat/domain/entities/message.dart';
import 'package:bsocial/features/chat/data/models/message_model.dart';
import 'package:bsocial/features/chat/data/models/message_model.dart'
    show MessageModel;
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that provides a stream of messages for a chat room
class MessageStream {
  /// Constructor
  MessageStream({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Get a stream of messages for a chat room
  Stream<List<MessageModel>> getMessageStream(String roomId) => _firestore
      .collection(AppConstants.chatsCollection)
      .doc(roomId)
      .collection(AppConstants.messagesCollection)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(MessageModel.fromSnapshot).toList());

  /// Add a message to the stream with optimistic update
  /// Returns a [MessageModel] with a temporary ID that will be updated
  /// when the message is successfully sent
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    // Generate a unique message ID
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();

    // Create message model
    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
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
      'lastMessageTime': timestamp,
      'lastMessageSenderId': senderId,
    });

    // Return the message with updated status
    return Future.value(MessageModel(
      messageId: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      isRead: false,
      roomId: roomId,
    ));
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId) async {
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
          doc.reference, {'isRead': true, 'status': MessageStatus.read.index});
    }

    // Commit the batch
    await batch.commit();
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId, String roomId) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .delete();
  }
}
