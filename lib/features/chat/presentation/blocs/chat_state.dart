part of 'chat_bloc.dart';

/// Base class for all chat states
abstract class ChatState extends Equatable {
  /// Constructor
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial chat state
class ChatInitial extends ChatState {}

/// Loading chat state
class ChatLoading extends ChatState {}

/// Chat rooms loaded state
class ChatRoomsLoaded extends ChatState {
  /// Constructor
  const ChatRoomsLoaded({required this.chatRooms});

  /// List of chat rooms
  final List<ChatRoom> chatRooms;

  @override
  List<Object> get props => [chatRooms];
}

/// Chat room created state
class ChatRoomCreated extends ChatState {
  /// Constructor
  const ChatRoomCreated({required this.chatRoom});

  /// Created chat room
  final ChatRoom chatRoom;

  @override
  List<Object> get props => [chatRoom];
}

/// Chat room loaded state
class ChatRoomLoaded extends ChatState {
  /// Constructor
  const ChatRoomLoaded({required this.chatRoom});

  /// Loaded chat room
  final ChatRoom chatRoom;

  @override
  List<Object> get props => [chatRoom];
}

/// Chat room not found state
class ChatRoomNotFound extends ChatState {}

/// Message sending state
class MessageSending extends ChatState {}

/// Message sent state
class MessageSent extends ChatState {
  /// Constructor
  const MessageSent({required this.message});

  /// Sent message
  final Message message;

  @override
  List<Object> get props => [message];
}

/// Messages loaded state
class MessagesLoaded extends ChatState {
  /// Constructor
  const MessagesLoaded({
    required this.messages,
    required this.chatRoom,
  });

  /// List of messages
  final List<Message> messages;

  /// Chat room
  final ChatRoom chatRoom;

  @override
  List<Object> get props => [messages, chatRoom];
}

/// Message deleted state
class MessageDeleted extends ChatState {}

/// Chat room deleted state
class ChatRoomDeleted extends ChatState {}

/// Chat error state
class ChatError extends ChatState {
  /// Constructor
  const ChatError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object> get props => [message];
}
