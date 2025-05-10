import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/usecases/create_chat_room.dart';
import '../../features/chat/domain/usecases/delete_chat_room.dart';
import '../../features/chat/domain/usecases/delete_message.dart';
import '../../features/chat/domain/usecases/get_chat_room_by_id.dart';
import '../../features/chat/domain/usecases/get_chat_room_by_participants.dart';
import '../../features/chat/domain/usecases/get_chat_rooms.dart';
import '../../features/chat/domain/usecases/get_messages.dart';
import '../../features/chat/domain/usecases/mark_messages_as_read.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/presentation/blocs/chat_bloc.dart';
import '../../features/home/presentation/blocs/home_bloc.dart';
import '../../features/post/data/repositories/cached_post_repository_impl.dart';
import '../../features/post/presentation/blocs/post_bloc.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/presentation/blocs/profile_bloc.dart';
import '../../features/search/domain/usecases/search_users.dart';
import '../../features/search/presentation/blocs/search_bloc.dart';

/// Provides BLoC providers for the application using feature-based architecture
class FeatureBlocProviders {
  /// Constructor
  FeatureBlocProviders({
    required AuthRepositoryImpl authRepository,
    required CachedPostRepositoryImpl postRepository,
    required ChatRepositoryImpl chatRepository,
  })  : _authRepository = authRepository,
        _postRepository = postRepository,
        _chatRepository = chatRepository;

  final AuthRepositoryImpl _authRepository;
  final CachedPostRepositoryImpl _postRepository;
  final ChatRepositoryImpl _chatRepository;

  /// Get all BLoC providers
  List<BlocProvider> getProviders() => [
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: _authRepository,
          )..add(CheckAuthStatusEvent()),
        ),

        // Post BLoC
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(
            postRepository: _postRepository,
          ),
        ),

        // Chat BLoC
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            getChatRoomsUseCase: GetChatRoomsUseCase(_chatRepository),
            createChatRoomUseCase: CreateChatRoomUseCase(_chatRepository),
            getChatRoomByIdUseCase: GetChatRoomByIdUseCase(_chatRepository),
            getChatRoomByParticipantsUseCase:
                GetChatRoomByParticipantsUseCase(_chatRepository),
            sendMessageUseCase: SendMessageUseCase(_chatRepository),
            getMessagesUseCase: GetMessagesUseCase(_chatRepository),
            markMessagesAsReadUseCase:
                MarkMessagesAsReadUseCase(_chatRepository),
            deleteMessageUseCase: DeleteMessageUseCase(_chatRepository),
            deleteChatRoomUseCase: DeleteChatRoomUseCase(_chatRepository),
          ),
        ),

        // Profile BLoC
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            getUserProfileUseCase: GetUserProfileUseCase(_authRepository),
            updateUserProfileUseCase: UpdateUserProfileUseCase(_authRepository),
          ),
        ),

        // Search BLoC
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            searchUsersUseCase: SearchUsersUseCase(_authRepository),
          ),
        ),

        // Home BLoC
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ];
}
