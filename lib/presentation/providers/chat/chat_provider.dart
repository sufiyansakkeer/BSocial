import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../domain/entities/chat_room.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/chat/create_chat_room.dart';
import '../../../domain/usecases/chat/get_chat_room_by_participants.dart';
import '../../../domain/usecases/chat/get_chat_rooms.dart';
import '../../../domain/usecases/chat/get_messages.dart';
import '../../../domain/usecases/chat/mark_messages_as_read.dart';
import '../../../domain/usecases/chat/send_message.dart';
import '../../../domain/usecases/user/get_user_by_id.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final CreateChatRoomUseCase _createChatRoomUseCase;
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkMessagesAsReadUseCase _markMessagesAsReadUseCase;
  final GetChatRoomByParticipantsUseCase _getChatRoomByParticipantsUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;

  ChatProvider({
    required CreateChatRoomUseCase createChatRoomUseCase,
    required GetChatRoomsUseCase getChatRoomsUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required MarkMessagesAsReadUseCase markMessagesAsReadUseCase,
    required GetChatRoomByParticipantsUseCase getChatRoomByParticipantsUseCase,
    required GetUserByIdUseCase getUserByIdUseCase,
  })  : _createChatRoomUseCase = createChatRoomUseCase,
        _getChatRoomsUseCase = getChatRoomsUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _markMessagesAsReadUseCase = markMessagesAsReadUseCase,
        _getChatRoomByParticipantsUseCase = getChatRoomByParticipantsUseCase,
        _getUserByIdUseCase = getUserByIdUseCase;

  // State variables
  ChatStatus _status = ChatStatus.initial;
  List<ChatRoom> _chatRooms = [];
  ChatRoom? _selectedChatRoom;
  List<Message> _messages = [];
  final Map<String, User> _chatUsers = {};
  String _errorMessage = '';

  // Getters
  ChatStatus get status => _status;
  List<ChatRoom> get chatRooms => _chatRooms;
  ChatRoom? get selectedChatRoom => _selectedChatRoom;
  List<Message> get messages => _messages;
  Map<String, User> get chatUsers => _chatUsers;
  String get errorMessage => _errorMessage;

  // Get all chat rooms for a user
  Future<void> getChatRooms(String userId) async {
    _status = ChatStatus.loading;
    notifyListeners();

    final result = await _getChatRoomsUseCase(userId);

    result.fold(
      (failure) {
        _status = ChatStatus.error;

        // Check if the error is related to missing Firestore index
        if (failure.message.contains('index') ||
            failure.message.contains('failed-precondition')) {
          // Try to extract the Firestore index URL from the error message
          String indexUrl = '';
          final urlMatch =
              RegExp(r'https://console\.firebase\.google\.com[^\s"]+')
                  .firstMatch(failure.message);
          if (urlMatch != null) {
            indexUrl = urlMatch.group(0) ?? '';
          }

          if (indexUrl.isNotEmpty) {
            _errorMessage =
                'The chat feature requires a Firestore index to be created.\n\n'
                'Please visit this URL to create the index:\n$indexUrl';
          } else {
            _errorMessage =
                'The chat feature requires a Firestore index to be created. '
                'Please check the console logs for the index creation URL or contact the app administrator.';
          }

          log('Firestore index error: ${failure.message}');
        } else {
          _errorMessage = failure.message;
          log('Error getting chat rooms: ${failure.message}');
        }
      },
      (chatRooms) {
        _chatRooms = chatRooms;
        _status = ChatStatus.loaded;

        // Load user data for each chat room
        _loadChatUsers(chatRooms, userId);
      },
    );

    notifyListeners();
  }

  // Load user data for chat rooms
  Future<void> _loadChatUsers(
      List<ChatRoom> chatRooms, String currentUserId) async {
    for (var room in chatRooms) {
      // Get the other participant's ID (not the current user)
      final otherUserId = room.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty && !_chatUsers.containsKey(otherUserId)) {
        final result = await _getUserByIdUseCase(otherUserId);

        result.fold(
          (failure) {
            log('Error getting user data: ${failure.message}');
          },
          (user) {
            _chatUsers[otherUserId] = user;
            notifyListeners();
          },
        );
      }
    }
  }

  // Get messages for a chat room
  Future<void> getMessages(String roomId) async {
    _status = ChatStatus.loading;
    notifyListeners();

    final result = await _getMessagesUseCase(roomId);

    result.fold(
      (failure) {
        _status = ChatStatus.error;
        _errorMessage = failure.message;
        log('Error getting messages: ${failure.message}');
      },
      (messages) {
        _messages = messages;
        _status = ChatStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Send a message
  Future<bool> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    _status = ChatStatus.loading;
    notifyListeners();

    final result = await _sendMessageUseCase(
      roomId: roomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    return result.fold(
      (failure) {
        _status = ChatStatus.error;
        _errorMessage = failure.message;
        log('Error sending message: ${failure.message}');
        notifyListeners();
        return false;
      },
      (message) {
        // Add the new message to the messages list
        _messages = [message, ..._messages];
        _status = ChatStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String roomId, String userId) async {
    final result = await _markMessagesAsReadUseCase(roomId, userId);

    return result.fold(
      (failure) {
        log('Error marking messages as read: ${failure.message}');
        return false;
      },
      (_) => true,
    );
  }

  // Create or get a chat room
  Future<ChatRoom?> createOrGetChatRoom(List<String> participants) async {
    _status = ChatStatus.loading;
    notifyListeners();

    // First check if a chat room already exists with these participants
    final existingRoomResult =
        await _getChatRoomByParticipantsUseCase(participants);

    return existingRoomResult.fold(
      (failure) {
        // If there was an error checking for existing room, try to create a new one
        return _createNewChatRoom(participants);
      },
      (existingRoom) {
        if (existingRoom != null) {
          _selectedChatRoom = existingRoom;
          _status = ChatStatus.loaded;
          notifyListeners();
          return existingRoom;
        } else {
          // No existing room found, create a new one
          return _createNewChatRoom(participants);
        }
      },
    );
  }

  // Helper method to create a new chat room
  Future<ChatRoom?> _createNewChatRoom(List<String> participants) async {
    final result = await _createChatRoomUseCase(participants);

    return result.fold(
      (failure) {
        _status = ChatStatus.error;
        _errorMessage = failure.message;
        log('Error creating chat room: ${failure.message}');
        notifyListeners();
        return null;
      },
      (chatRoom) {
        _selectedChatRoom = chatRoom;
        _status = ChatStatus.loaded;
        notifyListeners();
        return chatRoom;
      },
    );
  }

  // Set selected chat room
  void setSelectedChatRoom(ChatRoom chatRoom) {
    _selectedChatRoom = chatRoom;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
