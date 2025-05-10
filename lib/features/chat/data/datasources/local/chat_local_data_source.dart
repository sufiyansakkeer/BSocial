import 'dart:developer';
import 'package:hive/hive.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/chat_room_model.dart';
import '../../models/hive/chat_room_hive_model.dart';
import '../../models/hive/message_hive_model.dart';
import '../../models/message_model.dart';

/// Interface for chat local data source
abstract class ChatLocalDataSource {
  /// Cache a chat room
  Future<void> cacheChatRoom(ChatRoomModel chatRoom);

  /// Get all cached chat rooms for a user
  Future<List<ChatRoomModel>> getChatRooms(String userId);

  /// Get a cached chat room by ID
  Future<ChatRoomModel?> getChatRoomById(String roomId);

  /// Cache a message
  Future<void> cacheMessage(MessageModel message);

  /// Get all cached messages for a chat room
  Future<List<MessageModel>> getMessages(String roomId);

  /// Mark cached messages as read
  Future<void> markMessagesAsRead(String roomId, String userId);

  /// Delete a cached message
  Future<void> deleteMessage(String messageId, String roomId);

  /// Delete a cached chat room
  Future<void> deleteChatRoom(String roomId);

  /// Clear all cached chat rooms
  Future<void> clearChatRooms();

  /// Clear all cached messages
  Future<void> clearMessages();
}

/// Implementation of [ChatLocalDataSource]
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  /// Constructor
  ChatLocalDataSourceImpl();

  /// Box name for chat rooms
  static const String _chatRoomsBoxName = 'chat_rooms';

  /// Box name for messages
  static const String _messagesBoxName = 'messages';

  /// Get chat rooms box
  Future<Box<ChatRoomHiveModel>> get _chatRoomsBox async =>
      Hive.openBox<ChatRoomHiveModel>(_chatRoomsBoxName);

  /// Get messages box
  Future<Box<MessageHiveModel>> get _messagesBox async =>
      Hive.openBox<MessageHiveModel>(_messagesBoxName);

  @override
  Future<void> cacheChatRoom(ChatRoomModel chatRoom) async {
    try {
      final box = await _chatRoomsBox;
      final hiveModel = ChatRoomHiveModel.fromEntity(chatRoom);
      await box.put(chatRoom.roomId, hiveModel);
      log('Chat room cached: ${chatRoom.roomId}', name: 'cacheChatRoom');
    } catch (e) {
      log('Error caching chat room: $e', name: 'cacheChatRoom');
      throw CacheException(message: 'Failed to cache chat room: $e');
    }
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      final box = await _chatRoomsBox;
      return box.values
          .where((hiveModel) => hiveModel.participants.contains(userId))
          .map((hiveModel) => ChatRoomModel(
                roomId: hiveModel.roomId,
                participants: hiveModel.participants,
                lastMessageTime: hiveModel.lastMessageTime,
                lastMessage: hiveModel.lastMessage,
                lastMessageSenderId: hiveModel.lastMessageSenderId,
              ))
          .toList();
    } catch (e) {
      log('Error getting cached chat rooms: $e', name: 'getChatRooms');
      throw CacheException(message: 'Failed to get cached chat rooms: $e');
    }
  }

  @override
  Future<ChatRoomModel?> getChatRoomById(String roomId) async {
    try {
      final box = await _chatRoomsBox;
      final hiveModel = box.get(roomId);
      if (hiveModel == null) {
        return null;
      }
      return ChatRoomModel(
        roomId: hiveModel.roomId,
        participants: hiveModel.participants,
        lastMessageTime: hiveModel.lastMessageTime,
        lastMessage: hiveModel.lastMessage,
        lastMessageSenderId: hiveModel.lastMessageSenderId,
      );
    } catch (e) {
      log('Error getting cached chat room: $e', name: 'getChatRoomById');
      throw CacheException(message: 'Failed to get cached chat room: $e');
    }
  }

  @override
  Future<void> cacheMessage(MessageModel message) async {
    try {
      final box = await _messagesBox;
      final hiveModel = MessageHiveModel.fromEntity(message);
      await box.put(message.messageId, hiveModel);
      log('Message cached: ${message.messageId}', name: 'cacheMessage');
    } catch (e) {
      log('Error caching message: $e', name: 'cacheMessage');
      throw CacheException(message: 'Failed to cache message: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String roomId) async {
    try {
      final box = await _messagesBox;
      return box.values
          .where((hiveModel) => hiveModel.roomId == roomId)
          .map((hiveModel) => MessageModel(
                messageId: hiveModel.messageId,
                senderId: hiveModel.senderId,
                receiverId: hiveModel.receiverId,
                content: hiveModel.content,
                timestamp: hiveModel.timestamp,
                isRead: hiveModel.isRead,
                roomId: hiveModel.roomId,
              ))
          .toList();
    } catch (e) {
      log('Error getting cached messages: $e', name: 'getMessages');
      throw CacheException(message: 'Failed to get cached messages: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final box = await _messagesBox;
      final messagesToUpdate = box.values.where((hiveModel) =>
          hiveModel.roomId == roomId &&
          hiveModel.receiverId == userId &&
          !hiveModel.isRead);

      for (final message in messagesToUpdate) {
        final updatedMessage = MessageHiveModel(
          messageId: message.messageId,
          senderId: message.senderId,
          receiverId: message.receiverId,
          content: message.content,
          timestamp: message.timestamp,
          isRead: true,
          roomId: message.roomId,
          lastUpdated: DateTime.now(),
        );
        await box.put(message.messageId, updatedMessage);
      }
      log('Messages marked as read for room: $roomId, user: $userId',
          name: 'markMessagesAsRead');
    } catch (e) {
      log('Error marking messages as read: $e', name: 'markMessagesAsRead');
      throw CacheException(message: 'Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId, String roomId) async {
    try {
      final box = await _messagesBox;
      await box.delete(messageId);
      log('Message deleted from cache: $messageId', name: 'deleteMessage');
    } catch (e) {
      log('Error deleting cached message: $e', name: 'deleteMessage');
      throw CacheException(message: 'Failed to delete cached message: $e');
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      // Delete the chat room
      final chatRoomsBox = await _chatRoomsBox;
      await chatRoomsBox.delete(roomId);

      // Delete all messages in the chat room
      final messagesBox = await _messagesBox;
      final messagesToDelete = messagesBox.values
          .where((hiveModel) => hiveModel.roomId == roomId)
          .map((hiveModel) => hiveModel.messageId)
          .toList();

      for (final messageId in messagesToDelete) {
        await messagesBox.delete(messageId);
      }

      log('Chat room and messages deleted from cache: $roomId',
          name: 'deleteChatRoom');
    } catch (e) {
      log('Error deleting cached chat room: $e', name: 'deleteChatRoom');
      throw CacheException(message: 'Failed to delete cached chat room: $e');
    }
  }

  @override
  Future<void> clearChatRooms() async {
    try {
      final box = await _chatRoomsBox;
      await box.clear();
      log('All chat rooms cleared from cache', name: 'clearChatRooms');
    } catch (e) {
      log('Error clearing cached chat rooms: $e', name: 'clearChatRooms');
      throw CacheException(message: 'Failed to clear cached chat rooms: $e');
    }
  }

  @override
  Future<void> clearMessages() async {
    try {
      final box = await _messagesBox;
      await box.clear();
      log('All messages cleared from cache', name: 'clearMessages');
    } catch (e) {
      log('Error clearing cached messages: $e', name: 'clearMessages');
      throw CacheException(message: 'Failed to clear cached messages: $e');
    }
  }
}
