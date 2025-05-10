part of 'chat_bloc.dart';

/// Base class for all chat events
abstract class ChatEvent extends Equatable {
  /// Constructor
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load chat rooms
class LoadChatRoomsEvent extends ChatEvent {
  /// Constructor
  const LoadChatRoomsEvent({required this.userId});

  /// User ID
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to create a chat room
class CreateChatRoomEvent extends ChatEvent {
  /// Constructor
  const CreateChatRoomEvent({required this.participants});

  /// List of participant user IDs
  final List<String> participants;

  @override
  List<Object> get props => [participants];
}

/// Event to get a chat room by ID
class GetChatRoomByIdEvent extends ChatEvent {
  /// Constructor
  const GetChatRoomByIdEvent({required this.roomId});

  /// Chat room ID
  final String roomId;

  @override
  List<Object> get props => [roomId];
}

/// Event to get a chat room by participants
class GetChatRoomByParticipantsEvent extends ChatEvent {
  /// Constructor
  const GetChatRoomByParticipantsEvent({required this.participants});

  /// List of participant user IDs
  final List<String> participants;

  @override
  List<Object> get props => [participants];
}

/// Event to send a message
class SendMessageEvent extends ChatEvent {
  /// Constructor
  const SendMessageEvent({
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  /// Chat room ID
  final String roomId;

  /// Sender user ID
  final String senderId;

  /// Receiver user ID
  final String receiverId;

  /// Message content
  final String content;

  @override
  List<Object> get props => [roomId, senderId, receiverId, content];
}

/// Event to load messages
class LoadMessagesEvent extends ChatEvent {
  /// Constructor
  const LoadMessagesEvent({required this.roomId});

  /// Chat room ID
  final String roomId;

  @override
  List<Object> get props => [roomId];
}

/// Event to mark messages as read
class MarkMessagesAsReadEvent extends ChatEvent {
  /// Constructor
  const MarkMessagesAsReadEvent({
    required this.roomId,
    required this.userId,
  });

  /// Chat room ID
  final String roomId;

  /// User ID
  final String userId;

  @override
  List<Object> get props => [roomId, userId];
}

/// Event to delete a message
class DeleteMessageEvent extends ChatEvent {
  /// Constructor
  const DeleteMessageEvent({
    required this.messageId,
    required this.roomId,
  });

  /// Message ID
  final String messageId;

  /// Chat room ID
  final String roomId;

  @override
  List<Object> get props => [messageId, roomId];
}

/// Event to delete a chat room
class DeleteChatRoomEvent extends ChatEvent {
  /// Constructor
  const DeleteChatRoomEvent({required this.roomId});

  /// Chat room ID
  final String roomId;

  @override
  List<Object> get props => [roomId];
}

/// Event to set the selected chat room
class SetSelectedChatRoomEvent extends ChatEvent {
  /// Constructor
  const SetSelectedChatRoomEvent({required this.chatRoom});

  /// Chat room
  final ChatRoom chatRoom;

  @override
  List<Object> get props => [chatRoom];
}
