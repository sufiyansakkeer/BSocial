import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/create_chat_room.dart';
import '../../domain/usecases/delete_chat_room.dart';
import '../../domain/usecases/delete_message.dart';
import '../../domain/usecases/get_chat_room_by_id.dart';
import '../../domain/usecases/get_chat_room_by_participants.dart';
import '../../domain/usecases/get_chat_rooms.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/mark_messages_as_read.dart';
import '../../domain/usecases/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// BLoC for chat
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /// Constructor
  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.createChatRoomUseCase,
    required this.getChatRoomByIdUseCase,
    required this.getChatRoomByParticipantsUseCase,
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
    required this.markMessagesAsReadUseCase,
    required this.deleteMessageUseCase,
    required this.deleteChatRoomUseCase,
  }) : super(ChatInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<CreateChatRoomEvent>(_onCreateChatRoom);
    on<GetChatRoomByIdEvent>(_onGetChatRoomById);
    on<GetChatRoomByParticipantsEvent>(_onGetChatRoomByParticipants);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<DeleteChatRoomEvent>(_onDeleteChatRoom);
    on<SetSelectedChatRoomEvent>(_onSetSelectedChatRoom);
  }

  /// Get chat rooms use case
  final GetChatRoomsUseCase getChatRoomsUseCase;

  /// Create chat room use case
  final CreateChatRoomUseCase createChatRoomUseCase;

  /// Get chat room by ID use case
  final GetChatRoomByIdUseCase getChatRoomByIdUseCase;

  /// Get chat room by participants use case
  final GetChatRoomByParticipantsUseCase getChatRoomByParticipantsUseCase;

  /// Send message use case
  final SendMessageUseCase sendMessageUseCase;

  /// Get messages use case
  final GetMessagesUseCase getMessagesUseCase;

  /// Mark messages as read use case
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;

  /// Delete message use case
  final DeleteMessageUseCase deleteMessageUseCase;

  /// Delete chat room use case
  final DeleteChatRoomUseCase deleteChatRoomUseCase;

  /// Handle load chat rooms event
  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await getChatRoomsUseCase(event.userId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (chatRooms) => emit(ChatRoomsLoaded(chatRooms: chatRooms)),
    );
  }

  /// Handle create chat room event
  Future<void> _onCreateChatRoom(
    CreateChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await createChatRoomUseCase(event.participants);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (chatRoom) => emit(ChatRoomCreated(chatRoom: chatRoom)),
    );
  }

  /// Handle get chat room by ID event
  Future<void> _onGetChatRoomById(
    GetChatRoomByIdEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await getChatRoomByIdUseCase(event.roomId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (chatRoom) => emit(ChatRoomLoaded(chatRoom: chatRoom)),
    );
  }

  /// Handle get chat room by participants event
  Future<void> _onGetChatRoomByParticipants(
    GetChatRoomByParticipantsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await getChatRoomByParticipantsUseCase(event.participants);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (chatRoom) {
        if (chatRoom != null) {
          emit(ChatRoomLoaded(chatRoom: chatRoom));
        } else {
          emit(ChatRoomNotFound());
        }
      },
    );
  }

  /// Handle send message event
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessageSending());

    final result = await sendMessageUseCase(
      roomId: event.roomId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      content: event.content,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (message) {
        if (state is MessagesLoaded) {
          // If we already have messages loaded, just add the new message to the list
          final currentState = state as MessagesLoaded;
          final updatedMessages = [message, ...currentState.messages];

          // Also update the chat room's last message info
          final updatedChatRoom = currentState.chatRoom.copyWith(
            lastMessage: message.content,
            lastMessageTime: message.timestamp,
            lastMessageSenderId: message.senderId,
          );

          emit(MessagesLoaded(
            messages: updatedMessages,
            chatRoom: updatedChatRoom,
          ));
        } else {
          // If we don't have messages loaded yet, emit MessageSent
          // and let the UI handle reloading messages
          emit(MessageSent(message: message));
        }
      },
    );
  }

  /// Handle load messages event
  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    // First, get the chat room
    final chatRoomResult = await getChatRoomByIdUseCase(event.roomId);

    await chatRoomResult.fold(
      (failure) async {
        emit(ChatError(message: failure.message));
      },
      (chatRoom) async {
        // Then, get the messages
        final messagesResult = await getMessagesUseCase(event.roomId);

        messagesResult.fold(
          (failure) => emit(ChatError(message: failure.message)),
          (messages) => emit(MessagesLoaded(
            messages: messages,
            chatRoom: chatRoom,
          )),
        );
      },
    );
  }

  /// Handle mark messages as read event
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;

    final result = await markMessagesAsReadUseCase(
      event.roomId,
      event.userId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) {
        if (currentState is MessagesLoaded) {
          // Update the messages to mark them as read
          final updatedMessages = currentState.messages.map((message) {
            if (message.receiverId == event.userId && !message.isRead) {
              return message.copyWith(isRead: true);
            }
            return message;
          }).toList();

          emit(MessagesLoaded(
            messages: updatedMessages,
            chatRoom: currentState.chatRoom,
          ));
        }
      },
    );
  }

  /// Handle delete message event
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;

    final result = await deleteMessageUseCase(
      event.messageId,
      event.roomId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) {
        if (currentState is MessagesLoaded) {
          // Remove the deleted message from the list
          final updatedMessages = currentState.messages
              .where((message) => message.messageId != event.messageId)
              .toList();

          emit(MessagesLoaded(
            messages: updatedMessages,
            chatRoom: currentState.chatRoom,
          ));
        } else {
          emit(MessageDeleted());
        }
      },
    );
  }

  /// Handle delete chat room event
  Future<void> _onDeleteChatRoom(
    DeleteChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await deleteChatRoomUseCase(event.roomId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ChatRoomDeleted()),
    );
  }

  /// Handle set selected chat room event
  void _onSetSelectedChatRoom(
    SetSelectedChatRoomEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatRoomLoaded(chatRoom: event.chatRoom));
  }
}
