import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/post/domain/repositories/post_repository.dart'; // Added import
import '../../features/post/presentation/blocs/post_bloc.dart';
import '../../features/search/data/datasources/local/recent_searches_local_data_source.dart'; // Added import
import '../../features/search/domain/usecases/search_users.dart'; // Added import
import '../../features/search/presentation/blocs/search_bloc.dart';

/// Provides BLoC providers for the application
class BlocProviders {
  BlocProviders({
    required AuthRepositoryImpl authRepository,
    required PostRepository postRepository, // Changed type
    required SearchUsersUseCase searchUsersUseCase, // Added parameter
    required RecentSearchesLocalDataSource
        recentSearchesDataSource, // Added parameter
  })  : _authRepository = authRepository,
        _postRepository = postRepository,
        _searchUsersUseCase = searchUsersUseCase,
        _recentSearchesDataSource =
            recentSearchesDataSource; // Assigned parameter
  final AuthRepositoryImpl _authRepository;
  final PostRepository _postRepository; // Changed type
  final SearchUsersUseCase _searchUsersUseCase; // Added field
  final RecentSearchesLocalDataSource _recentSearchesDataSource; // Added field

  /// Get all BLoC providers
  List<BlocProvider> getProviders() => [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: _authRepository,
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(
            postRepository: _postRepository,
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            searchUsersUseCase: _searchUsersUseCase,
            recentSearchesDataSource:
                _recentSearchesDataSource, // Passed parameter
          ),
        ),
      ];
}
