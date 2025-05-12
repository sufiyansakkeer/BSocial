import 'dart:async';
import 'dart:developer' as dev;

import 'package:async/async.dart';
import 'package:bsocial/core/constants/app_constants.dart';
import 'package:bsocial/core/services/cache_manager.dart';
import 'package:bsocial/features/chat/data/models/message_model.dart';
import 'package:bsocial/features/chat/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A class that provides a stream of messages for a chat room
class MessageStream {
  /// Constructor
  MessageStream({
    required FirebaseFirestore firestore,
    required Connectivity connectivity,
  })  : _firestore = firestore,
        _connectivity = connectivity {
    // Initialize connectivity monitoring
    _initConnectivityMonitoring();
  }

  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  // Cache for pending messages that need to be sent when
  // connectivity is restored
  final List<Map<String, dynamic>> _pendingMessages = [];

  // Flag to track connectivity status
  bool _isConnected = true;

  // Stream controller for local message updates
  final StreamController<List<MessageModel>> _localMessagesController =
      StreamController<List<MessageModel>>.broadcast();

  // Cache for the most recent messages to reduce Firestore reads
  final Map<String, List<MessageModel>> _messageCache = {};

  // Maximum number of messages to cache per room
  static const int _maxCachedMessages = 50;

  // Default page size for pagination
  static const int _defaultPageSize = 20;

  // Store the last document for pagination
  final Map<String, DocumentSnapshot> _lastVisibleDocuments = {};

  // Track if there are more messages to load for each room
  final Map<String, bool> _hasMoreMessages = {};

  // Log messages with a tag
  void _log(String message, {String tag = 'MessageStream'}) {
    dev.log(message, name: tag);
  }

  /// Initialize connectivity monitoring
  void _initConnectivityMonitoring() {
    _connectivity.onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;

      // If connectivity was restored, send pending messages
      if (!wasConnected && _isConnected && _pendingMessages.isNotEmpty) {
        _sendPendingMessages();
      }
    });
  }

  /// Send all pending messages when connectivity is restored
  Future<void> _sendPendingMessages() async {
    if (_pendingMessages.isEmpty) {
      return;
    }

    final pendingMessagesCopy =
        List<Map<String, dynamic>>.from(_pendingMessages);
    _pendingMessages.clear();

    for (final messageData in pendingMessagesCopy) {
      try {
        await sendMessage(
          roomId: messageData['roomId'],
          senderId: messageData['senderId'],
          receiverId: messageData['receiverId'],
          content: messageData['content'],
          pendingMessageId: messageData['messageId'],
        );
      } on Exception catch (e) {
        // If sending fails, add back to pending messages
        _log('Failed to send pending message: $e');
        _pendingMessages.add(messageData);
      }
    }
  }

  /// Get a stream of messages for a chat room with optimized caching
  /// and pagination support
  Stream<List<MessageModel>> getMessageStream(String roomId) {
    // Initialize hasMoreMessages for this room if not already set
    _hasMoreMessages.putIfAbsent(roomId, () => true);

    // Check if we have cached messages for this room
    final cachedMessages = _messageCache[roomId];

    // Create a stream controller to emit messages
    final controller = StreamController<List<MessageModel>>.broadcast();

    // If we have cached messages, emit them immediately
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      controller.add(cachedMessages);

      // Mark the chat room as visited
      CacheManager().markScreenVisited('chat_$roomId');

      // Check if we need to refresh in the background
      CacheManager()
          .hasValidCache('chat_messages_$roomId',
              maxAge: const Duration(minutes: 5))
          .then((hasValidCache) {
        if (!hasValidCache) {
          // If cache is expired, refresh in the background
          _refreshMessagesInBackground(roomId, controller);
        }
      });
    } else {
      // No cache, show loading state and fetch from Firestore
      _fetchMessagesFromFirestore(roomId, controller);
    }

    // Create a merged stream that combines Firestore updates with local updates
    final localUpdates = _localMessagesController.stream
        .where((messages) => messages.any((msg) => msg.roomId == roomId));

    // Merge the controller stream with local updates
    return StreamGroup.merge([controller.stream, localUpdates]);
  }

  /// Fetch messages from Firestore and update the controller
  void _fetchMessagesFromFirestore(
      String roomId, StreamController<List<MessageModel>> controller) {
    _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(_defaultPageSize) // Initial page size
        .get()
        .then((snapshot) {
      final messages = snapshot.docs.map(MessageModel.fromSnapshot).toList();

      // Store the last visible document for pagination if we have results
      if (snapshot.docs.isNotEmpty) {
        _lastVisibleDocuments[roomId] = snapshot.docs.last;
        // If we got fewer messages than requested, there are no more to load
        _hasMoreMessages[roomId] = snapshot.docs.length >= _defaultPageSize;
      } else {
        _hasMoreMessages[roomId] = false;
      }

      // Update cache
      _messageCache[roomId] = messages;

      // Mark cache as refreshed
      CacheManager().markCacheRefreshed('chat_messages_$roomId');

      // Emit messages to the controller
      controller.add(messages);

      // Set up the real-time listener for future updates
      _setupRealtimeListener(roomId, controller);
    }).catchError((error) {
      _log('Error fetching messages: $error');
      // If there's an error, still set up the listener for future updates
      _setupRealtimeListener(roomId, controller);
    });
  }

  /// Refresh messages in the background without disrupting the UI
  void _refreshMessagesInBackground(
      String roomId, StreamController<List<MessageModel>> controller) {
    _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(_defaultPageSize) // Initial page size
        .get()
        .then((snapshot) {
      final messages = snapshot.docs.map(MessageModel.fromSnapshot).toList();

      // Store the last visible document for pagination if we have results
      if (snapshot.docs.isNotEmpty) {
        _lastVisibleDocuments[roomId] = snapshot.docs.last;
        // If we got fewer messages than requested, there are no more to load
        _hasMoreMessages[roomId] = snapshot.docs.length >= _defaultPageSize;
      } else {
        _hasMoreMessages[roomId] = false;
      }

      // Check if the messages are different from the cache
      final cachedMessages = _messageCache[roomId] ?? [];
      final hasChanges = _messagesHaveChanged(cachedMessages, messages);

      if (hasChanges) {
        // Update cache
        _messageCache[roomId] = messages;

        // Emit messages to the controller
        controller.add(messages);
      }

      // Mark cache as refreshed
      CacheManager().markCacheRefreshed('chat_messages_$roomId');

      // Set up the real-time listener for future updates
      _setupRealtimeListener(roomId, controller);
    }).catchError((error) {
      _log('Error refreshing messages: $error');
      // If there's an error, still set up the listener for future updates
      _setupRealtimeListener(roomId, controller);
    });
  }

  /// Set up a real-time listener for new messages
  void _setupRealtimeListener(
      String roomId, StreamController<List<MessageModel>> controller) {
    // Listen for real-time updates
    _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(_defaultPageSize)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map(MessageModel.fromSnapshot).toList();

      // Update cache
      _messageCache[roomId] = messages;

      // Emit messages to the controller
      controller.add(messages);

      // Mark cache as refreshed
      CacheManager().markCacheRefreshed('chat_messages_$roomId');
    }, onError: (error) {
      _log('Error in real-time listener: $error');
    });
  }

  /// Check if messages have changed
  bool _messagesHaveChanged(
      List<MessageModel> oldMessages, List<MessageModel> newMessages) {
    if (oldMessages.length != newMessages.length) {
      return true;
    }

    for (var i = 0; i < oldMessages.length; i++) {
      if (oldMessages[i].messageId != newMessages[i].messageId ||
          oldMessages[i].content != newMessages[i].content ||
          oldMessages[i].isRead != newMessages[i].isRead ||
          oldMessages[i].status != newMessages[i].status) {
        return true;
      }
    }

    return false;
  }

  /// Load more messages for pagination
  /// Returns a list of older messages and a boolean indicating if there are
  /// more messages to load
  Future<(List<MessageModel>, bool)> loadMoreMessages(String roomId,
      {int pageSize = 20}) async {
    // If we don't have more messages or no last document, return empty list
    if (_hasMoreMessages[roomId] == false ||
        !_lastVisibleDocuments.containsKey(roomId)) {
      return (<MessageModel>[], false);
    }

    try {
      // Get the next page of messages
      final query = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .collection(AppConstants.messagesCollection)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastVisibleDocuments[roomId]!)
          .limit(pageSize);

      final snapshot = await query.get();
      final messages = snapshot.docs.map(MessageModel.fromSnapshot).toList();

      // Update the last visible document if we have results
      if (snapshot.docs.isNotEmpty) {
        _lastVisibleDocuments[roomId] = snapshot.docs.last;
        // If we got fewer messages than requested, there are no more to load
        _hasMoreMessages[roomId] = snapshot.docs.length >= pageSize;
      } else {
        _hasMoreMessages[roomId] = false;
      }

      // Add to cache
      if (messages.isNotEmpty) {
        _messageCache[roomId]?.addAll(messages);

        // Trim cache if it exceeds maximum size
        if (_messageCache[roomId]!.length > _maxCachedMessages) {
          _messageCache[roomId] =
              _messageCache[roomId]!.sublist(0, _maxCachedMessages);
        }

        // Notify listeners of the updated cache
        _localMessagesController.add(_messageCache[roomId]!);
      }

      return (messages, _hasMoreMessages[roomId]!);
    } on Exception catch (e) {
      _log('Error loading more messages: $e');
      return (<MessageModel>[], false);
    }
  }

  /// Check if there are more messages to load for a chat room
  bool hasMoreMessages(String roomId) => _hasMoreMessages[roomId] ?? false;

  /// Reset pagination for a chat room
  void resetPagination(String roomId) {
    _lastVisibleDocuments.remove(roomId);
    _hasMoreMessages[roomId] = true;
  }

  /// Add a message to the stream with optimistic update and offline support
  /// Returns a [MessageModel] with a temporary ID that will be updated
  /// when the message is successfully sent
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
    String? pendingMessageId,
  }) async {
    // Generate a unique message ID
    final messageId =
        pendingMessageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();

    // Create message model with initial "sending" status
    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      isRead: false,
      roomId: roomId,
      status: MessageStatus.sending,
    );

    // Add to local cache immediately for optimistic UI update
    _updateLocalMessageCache(roomId, message);

    // If offline, store in pending messages and return the message with
    // "sending" status
    if (!_isConnected) {
      _pendingMessages.add({
        'messageId': messageId,
        'roomId': roomId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      });

      // Update message status to failed if offline
      final failedMessage = MessageModel(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: timestamp,
        isRead: false,
        roomId: roomId,
        status: MessageStatus.failed,
      );
      _updateLocalMessageCache(roomId, failedMessage);

      return failedMessage;
    }

    try {
      // Create a message with sent status
      final sentMessage = MessageModel(
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
          .set(sentMessage.toJson());

      // Update chat room with last message info
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(roomId)
          .update({
        'lastMessage': content,
        'lastMessageTime': timestamp,
        'lastMessageSenderId': senderId,
      });
      _updateLocalMessageCache(roomId, sentMessage);

      return sentMessage;
    } on Exception catch (e) {
      _log('Failed to send message: $e');

      // If sending fails, update status to failed and add to pending messages
      final failedMessage = MessageModel(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: timestamp,
        isRead: false,
        roomId: roomId,
        status: MessageStatus.failed,
      );
      _updateLocalMessageCache(roomId, failedMessage);

      _pendingMessages.add({
        'messageId': messageId,
        'roomId': roomId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      });

      return failedMessage;
    }
  }

  /// Update the local message cache and notify listeners
  void _updateLocalMessageCache(String roomId, MessageModel message) {
    // Initialize cache for this room if it doesn't exist
    _messageCache.putIfAbsent(roomId, () => []);

    // Find and replace existing message or add new one
    final index = _messageCache[roomId]!
        .indexWhere((m) => m.messageId == message.messageId);

    if (index >= 0) {
      _messageCache[roomId]![index] = message;
    } else {
      _messageCache[roomId]!.insert(0, message);

      // Trim cache if it exceeds maximum size
      if (_messageCache[roomId]!.length > _maxCachedMessages) {
        _messageCache[roomId]!.removeLast();
      }
    }

    // Notify listeners
    _localMessagesController.add(_messageCache[roomId]!);
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
