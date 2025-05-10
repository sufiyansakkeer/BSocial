import 'dart:developer';
import 'package:hive/hive.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/chat_room.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/post.dart';
import '../../../features/user/domain/entities/user.dart';
import '../../models/hive/chat_room_hive_model.dart';
import '../../models/hive/comment_hive_model.dart';
import '../../models/hive/message_hive_model.dart';
import '../../models/hive/post_hive_model.dart';
import '../../models/hive/user_hive_model.dart';

abstract class HiveLocalDataSource {
  // User operations
  Future<void> cacheUser(User user);
  Future<User?> getUser(String userId);
  Future<List<User>> getAllUsers();
  Future<void> deleteUser(String userId);

  // Post operations
  Future<void> cachePost(Post post);
  Future<Post?> getPost(String postId);
  Future<List<Post>> getAllPosts();
  Future<List<Post>> getPostsByUserId(String userId);
  Future<void> deletePost(String postId);
  Future<void> updatePostLikes(String postId, List<String> likes);

  // Comment operations
  Future<void> cacheComment(Comment comment);
  Future<List<Comment>> getCommentsByPostId(String postId);
  Future<void> deleteComment(String commentId);

  // Chat operations
  Future<void> cacheChatRoom(ChatRoom chatRoom);
  Future<ChatRoom?> getChatRoom(String roomId);
  Future<List<ChatRoom>> getChatRoomsByUserId(String userId);
  Future<void> deleteChatRoom(String roomId);

  // Message operations
  Future<void> cacheMessage(Message message);
  Future<List<Message>> getMessagesByChatRoomId(String roomId);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessagesAsRead(String roomId, String userId);

  // Cache management
  Future<void> clearCache();
  Future<void> clearExpiredCache(Duration maxAge);
}

class HiveLocalDataSourceImpl implements HiveLocalDataSource {
  static const String _userBoxName = 'users';
  static const String _postBoxName = 'posts';
  static const String _commentBoxName = 'comments';
  static const String _chatRoomBoxName = 'chatRooms';
  static const String _messageBoxName = 'messages';

  // User operations
  @override
  Future<void> cacheUser(User user) async {
    try {
      final userBox = await _getBox<UserHiveModel>(_userBoxName);
      final userModel = UserHiveModel.fromEntity(user);
      await userBox.put(user.uid, userModel);
    } catch (e) {
      log('Error caching user: $e', name: 'cacheUser');
      throw CacheException(message: 'Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<User?> getUser(String userId) async {
    try {
      final userBox = await _getBox<UserHiveModel>(_userBoxName);
      final userModel = userBox.get(userId);
      return userModel?.toEntity();
    } catch (e) {
      log('Error getting user from cache: $e', name: 'getUser');
      throw CacheException(
          message: 'Failed to get user from cache: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final userBox = await _getBox<UserHiveModel>(_userBoxName);
      return userBox.values.map((model) => model.toEntity()).toList();
    } catch (e) {
      log('Error getting all users from cache: $e', name: 'getAllUsers');
      throw CacheException(
          message: 'Failed to get all users from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final userBox = await _getBox<UserHiveModel>(_userBoxName);
      await userBox.delete(userId);
    } catch (e) {
      log('Error deleting user from cache: $e', name: 'deleteUser');
      throw CacheException(
          message: 'Failed to delete user from cache: ${e.toString()}');
    }
  }

  // Post operations
  /// Helper method to get a Hive box safely
  Future<Box<T>> _getBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      } else {
        return await Hive.openBox<T>(boxName);
      }
    } on Exception catch (e) {
      log('Error opening box $boxName: $e', name: '_getBox');
      // Try to delete and recreate the box if there's an issue
      try {
        if (await Hive.boxExists(boxName)) {
          await Hive.deleteBoxFromDisk(boxName);
        }
        return await Hive.openBox<T>(boxName);
      } on Exception catch (e) {
        log('Failed to recover box $boxName: $e', name: '_getBox');
        rethrow;
      }
    }
  }

  @override
  Future<void> cachePost(Post post) async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final postModel = PostHiveModel.fromEntity(post);
      await postBox.put(post.postId, postModel);
    } catch (e) {
      log('Error caching post: $e', name: 'cachePost');
      throw CacheException(message: 'Failed to cache post: ${e.toString()}');
    }
  }

  @override
  Future<Post?> getPost(String postId) async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final postModel = postBox.get(postId);
      return postModel?.toEntity();
    } catch (e) {
      log('Error getting post from cache: $e', name: 'getPost');
      throw CacheException(
          message: 'Failed to get post from cache: ${e.toString()}');
    }
  }

  @override
  Future<List<Post>> getAllPosts() async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final posts = postBox.values.map((model) => model.toEntity()).toList()
        // Sort by date published (newest first)
        ..sort((a, b) => b.datePublished.compareTo(a.datePublished));

      return posts;
    } catch (e) {
      log('Error getting all posts from cache: $e', name: 'getAllPosts');
      throw CacheException(
          message: 'Failed to get all posts from cache: ${e.toString()}');
    }
  }

  @override
  Future<List<Post>> getPostsByUserId(String userId) async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final posts = postBox.values
          .where((post) => post.uid == userId)
          .map((model) => model.toEntity())
          .toList()
        // Sort by date published (newest first)
        ..sort((a, b) => b.datePublished.compareTo(a.datePublished));

      return posts;
    } catch (e) {
      log('Error getting user posts from cache: $e', name: 'getPostsByUserId');
      throw CacheException(
          message: 'Failed to get user posts from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      await postBox.delete(postId);

      // Also delete associated comments
      final commentBox = await _getBox<CommentHiveModel>(_commentBoxName);
      final commentsToDelete = commentBox.values
          .where((comment) => comment.postId == postId)
          .toList();

      for (final comment in commentsToDelete) {
        await commentBox.delete(comment.commentId);
      }
    } catch (e) {
      log('Error deleting post from cache: $e', name: 'deletePost');
      throw CacheException(
          message: 'Failed to delete post from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePostLikes(String postId, List<String> likes) async {
    try {
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final postModel = postBox.get(postId);

      if (postModel != null) {
        final updatedPost = Post(
          postId: postModel.postId,
          uid: postModel.uid,
          username: postModel.username,
          description: postModel.description,
          postUrl: postModel.postUrl,
          profImage: postModel.profImage,
          datePublished: postModel.datePublished,
          likes: likes,
        );

        await cachePost(updatedPost);
      }
    } catch (e) {
      log('Error updating post likes in cache: $e', name: 'updatePostLikes');
      throw CacheException(
          message: 'Failed to update post likes in cache: ${e.toString()}');
    }
  }

  // Comment operations
  @override
  Future<void> cacheComment(Comment comment) async {
    try {
      final commentBox = await _getBox<CommentHiveModel>(_commentBoxName);
      final commentModel = CommentHiveModel.fromEntity(comment);
      await commentBox.put(comment.commentId, commentModel);
    } catch (e) {
      log('Error caching comment: $e', name: 'cacheComment');
      throw CacheException(message: 'Failed to cache comment: ${e.toString()}');
    }
  }

  @override
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    try {
      final commentBox = await _getBox<CommentHiveModel>(_commentBoxName);
      final comments = commentBox.values
          .where((comment) => comment.postId == postId)
          .map((model) => model.toEntity())
          .toList()
        // Sort by date published (newest first)
        ..sort((a, b) => b.datePublished.compareTo(a.datePublished));

      return comments;
    } catch (e) {
      log('Error getting comments from cache: $e', name: 'getCommentsByPostId');
      throw CacheException(
          message: 'Failed to get comments from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final commentBox = await _getBox<CommentHiveModel>(_commentBoxName);
      await commentBox.delete(commentId);
    } catch (e) {
      log('Error deleting comment from cache: $e', name: 'deleteComment');
      throw CacheException(
          message: 'Failed to delete comment from cache: ${e.toString()}');
    }
  }

  // Chat operations
  @override
  Future<void> cacheChatRoom(ChatRoom chatRoom) async {
    try {
      final chatRoomBox = await _getBox<ChatRoomHiveModel>(_chatRoomBoxName);
      final chatRoomModel = ChatRoomHiveModel.fromEntity(chatRoom);
      await chatRoomBox.put(chatRoom.roomId, chatRoomModel);
    } catch (e) {
      log('Error caching chat room: $e', name: 'cacheChatRoom');
      throw CacheException(
          message: 'Failed to cache chat room: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoom?> getChatRoom(String roomId) async {
    try {
      final chatRoomBox = await _getBox<ChatRoomHiveModel>(_chatRoomBoxName);
      final chatRoomModel = chatRoomBox.get(roomId);
      return chatRoomModel?.toEntity();
    } catch (e) {
      log('Error getting chat room from cache: $e', name: 'getChatRoom');
      throw CacheException(
          message: 'Failed to get chat room from cache: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatRoom>> getChatRoomsByUserId(String userId) async {
    try {
      final chatRoomBox = await _getBox<ChatRoomHiveModel>(_chatRoomBoxName);
      final chatRooms = chatRoomBox.values
          .where((room) => room.participants.contains(userId))
          .map((model) => model.toEntity())
          .toList()
        // Sort by last message time (newest first)
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return chatRooms;
    } catch (e) {
      log('Error getting chat rooms from cache: $e',
          name: 'getChatRoomsByUserId');
      throw CacheException(
          message: 'Failed to get chat rooms from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      final chatRoomBox = await _getBox<ChatRoomHiveModel>(_chatRoomBoxName);
      await chatRoomBox.delete(roomId);

      // Also delete associated messages
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);

      // Get all keys in the box
      final allKeys = messageBox.keys.toList();

      // Filter keys that start with the roomId
      final keysToDelete = allKeys
          .where((key) => key.toString().startsWith('$roomId:'))
          .toList();

      // Delete all messages for this room
      for (final key in keysToDelete) {
        await messageBox.delete(key);
      }
    } catch (e) {
      log('Error deleting chat room from cache: $e', name: 'deleteChatRoom');
      throw CacheException(
          message: 'Failed to delete chat room from cache: ${e.toString()}');
    }
  }

  // Message operations
  @override
  Future<void> cacheMessage(Message message) async {
    try {
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);
      final messageModel = MessageHiveModel.fromEntity(message);
      // Use a composite key: roomId:messageId
      final compositeKey = '${message.roomId}:${message.messageId}';
      await messageBox.put(compositeKey, messageModel);
    } catch (e) {
      log('Error caching message: $e', name: 'cacheMessage');
      throw CacheException(message: 'Failed to cache message: ${e.toString()}');
    }
  }

  @override
  Future<List<Message>> getMessagesByChatRoomId(String roomId) async {
    try {
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);

      // Get all keys in the box
      final allKeys = messageBox.keys.toList();

      // Filter keys that start with the roomId
      final roomKeys = allKeys
          .where((key) => key.toString().startsWith('$roomId:'))
          .toList();

      // Get messages for this room
      final messages = <Message>[];
      for (final key in roomKeys) {
        final message = messageBox.get(key);
        if (message != null) {
          messages.add(message.toEntity());
        }
      }

      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return messages;
    } catch (e) {
      log('Error getting messages from cache: $e',
          name: 'getMessagesByChatRoomId');
      throw CacheException(
          message: 'Failed to get messages from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);
      // Find the message with the given ID (part of the composite key)
      final keysToDelete = messageBox.keys
          .where((key) => key.toString().endsWith(':$messageId'))
          .toList();

      for (final key in keysToDelete) {
        await messageBox.delete(key);
      }
    } catch (e) {
      log('Error deleting message from cache: $e', name: 'deleteMessage');
      throw CacheException(
          message: 'Failed to delete message from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);

      // Get all keys in the box
      final allKeys = messageBox.keys.toList();

      // Filter keys that start with the roomId
      final roomKeys = allKeys
          .where((key) => key.toString().startsWith('$roomId:'))
          .toList();

      // Get messages that need to be updated
      final messagesToUpdate = <String, MessageHiveModel>{};
      for (final key in roomKeys) {
        final message = messageBox.get(key);
        if (message != null &&
            message.receiverId == userId &&
            !message.isRead) {
          messagesToUpdate[key.toString()] = message;
        }
      }

      // Update messages
      for (final entry in messagesToUpdate.entries) {
        final message = entry.value;

        // Create updated message
        final updatedMessage = Message(
          messageId: message.messageId,
          senderId: message.senderId,
          receiverId: message.receiverId,
          content: message.content,
          timestamp: message.timestamp,
          isRead: true,
          roomId: roomId,
        );

        // Cache the updated message (this will overwrite the existing one)
        await cacheMessage(updatedMessage);
      }
    } catch (e) {
      log('Error marking messages as read in cache: $e',
          name: 'markMessagesAsRead');
      throw CacheException(
          message: 'Failed to mark messages as read in cache: ${e.toString()}');
    }
  }

  // Cache management
  @override
  Future<void> clearCache() async {
    try {
      await Hive.deleteBoxFromDisk(_userBoxName);
      await Hive.deleteBoxFromDisk(_postBoxName);
      await Hive.deleteBoxFromDisk(_commentBoxName);
      await Hive.deleteBoxFromDisk(_chatRoomBoxName);
      await Hive.deleteBoxFromDisk(_messageBoxName);
    } catch (e) {
      log('Error clearing cache: $e', name: 'clearCache');
      throw CacheException(message: 'Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearExpiredCache(Duration maxAge) async {
    final now = DateTime.now();

    try {
      // Clear expired users
      final userBox = await _getBox<UserHiveModel>(_userBoxName);
      final expiredUsers = userBox.values
          .where((user) => now.difference(user.lastUpdated) > maxAge)
          .toList();

      for (final user in expiredUsers) {
        await userBox.delete(user.uid);
      }

      // Clear expired posts
      final postBox = await _getBox<PostHiveModel>(_postBoxName);
      final expiredPosts = postBox.values
          .where((post) => now.difference(post.lastUpdated) > maxAge)
          .toList();

      for (final post in expiredPosts) {
        await postBox.delete(post.postId);
      }

      // Clear expired comments
      final commentBox = await _getBox<CommentHiveModel>(_commentBoxName);
      final expiredComments = commentBox.values
          .where((comment) => now.difference(comment.lastUpdated) > maxAge)
          .toList();

      for (final comment in expiredComments) {
        await commentBox.delete(comment.commentId);
      }

      // Clear expired chat rooms
      final chatRoomBox = await _getBox<ChatRoomHiveModel>(_chatRoomBoxName);
      final expiredChatRooms = chatRoomBox.values
          .where((room) => now.difference(room.lastUpdated) > maxAge)
          .toList();

      for (final room in expiredChatRooms) {
        await chatRoomBox.delete(room.roomId);
      }

      // Clear expired messages
      final messageBox = await _getBox<MessageHiveModel>(_messageBoxName);

      // Get all keys and their values
      final allKeys = messageBox.keys.toList();
      final messageEntries = <dynamic, MessageHiveModel>{};

      for (final key in allKeys) {
        final message = messageBox.get(key);
        if (message != null) {
          messageEntries[key] = message;
        }
      }

      // Find expired messages
      final expiredKeys = <dynamic>[];
      for (final entry in messageEntries.entries) {
        if (now.difference(entry.value.lastUpdated) > maxAge) {
          expiredKeys.add(entry.key);
        }
      }

      // Delete expired messages
      for (final key in expiredKeys) {
        await messageBox.delete(key);
      }
    } catch (e) {
      log('Error clearing expired cache: $e', name: 'clearExpiredCache');
      throw CacheException(
          message: 'Failed to clear expired cache: ${e.toString()}');
    }
  }
}
