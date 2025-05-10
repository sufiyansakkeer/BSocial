import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/firebase_utils.dart';
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
import '../../features/search/data/datasources/local/recent_searches_local_data_source.dart';
import '../../features/search/data/models/recent_search_model.dart';
import '../../features/search/domain/usecases/search_users.dart';
import '../../features/search/presentation/blocs/search_bloc.dart';

/// Empty implementation of [RecentSearchesLocalDataSource] for initialization
class _EmptyRecentSearchesDataSource implements RecentSearchesLocalDataSource {
  @override
  Future<void> clearRecentSearches() async {}

  @override
  Future<List<RecentSearchModel>> getRecentSearches() async => [];

  @override
  Future<void> saveRecentSearch(RecentSearchModel search) async {}
}

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

  /// Create an empty data source for the search bloc
  RecentSearchesLocalDataSource _createEmptyDataSource() =>
      _EmptyRecentSearchesDataSource();

  /// Initialize the search bloc with the real data source
  Future<void> _initializeSearchBloc(SearchBloc searchBloc) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final dataSource = RecentSearchesLocalDataSourceImpl(
        sharedPreferences: sharedPreferences,
      );

      // We can't replace the data source directly, so we'll just
      // load the recent searches and add them to the bloc
      await dataSource.getRecentSearches();
      searchBloc.add(LoadRecentSearchesEvent());
    } on Exception {
      // Silently fail - this is not critical functionality
    }
  }

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
            onMissingIndexError: FirebaseUtils.showMissingIndexDialog,
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
          lazy: false,
          create: (context) {
            // Create a SearchBloc with a temporary empty data source
            final searchBloc = SearchBloc(
              searchUsersUseCase: SearchUsersUseCase(_authRepository),
              recentSearchesDataSource: _createEmptyDataSource(),
            );

            // Initialize the real data source in the background
            _initializeSearchBloc(searchBloc);

            return searchBloc;
          },
        ),

        // Home BLoC
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ];
}
