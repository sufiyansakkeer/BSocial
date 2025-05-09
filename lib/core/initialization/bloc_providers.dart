import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cached_post_repository_impl.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/post/post_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';

/// Provides BLoC providers for the application
class BlocProviders {

  BlocProviders({
    required AuthRepositoryImpl authRepository,
    required CachedPostRepositoryImpl postRepository,
  })  : _authRepository = authRepository,
        _postRepository = postRepository;
  final AuthRepositoryImpl _authRepository;
  final CachedPostRepositoryImpl _postRepository;

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
        create: (context) => SearchBloc(),
      ),
    ];
}
