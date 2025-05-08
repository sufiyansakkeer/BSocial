import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../core/network/network_info.dart';
import '../data/datasources/local/hive_local_data_source.dart';
import '../data/datasources/local/storage_local_data_source.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/remote/chat_remote_data_source.dart';
import '../data/datasources/remote/post_remote_data_source.dart';
import '../data/datasources/remote/user_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/cached_chat_repository_impl.dart';
import '../data/repositories/cached_post_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/post_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/auth/get_current_user.dart';
import '../domain/usecases/auth/login_user.dart';
import '../domain/usecases/auth/sign_in_with_google.dart';
import '../domain/usecases/auth/sign_out_user.dart';
import '../domain/usecases/auth/sign_up_user.dart';
import '../domain/usecases/chat/create_chat_room.dart';
import '../domain/usecases/chat/get_chat_room_by_participants.dart';
import '../domain/usecases/chat/get_chat_rooms.dart';
import '../domain/usecases/chat/get_messages.dart';
import '../domain/usecases/chat/mark_messages_as_read.dart';
import '../domain/usecases/chat/send_message.dart';
import '../domain/usecases/post/create_post.dart';
import '../domain/usecases/post/delete_comment.dart';
import '../domain/usecases/post/delete_post.dart';
import '../domain/usecases/post/get_all_posts.dart';
import '../domain/usecases/post/get_comments.dart';
import '../domain/usecases/post/get_posts_by_user_id.dart';
import '../domain/usecases/post/like_post.dart';
import '../domain/usecases/post/post_comment.dart';
import '../domain/usecases/post/unlike_post.dart';
import '../domain/usecases/user/follow_user.dart';
import '../domain/usecases/user/get_all_users.dart';
import '../domain/usecases/user/get_followers.dart';
import '../domain/usecases/user/get_following.dart';
import '../domain/usecases/user/get_user_by_id.dart';
import '../domain/usecases/user/search_users.dart';
import '../domain/usecases/user/unfollow_user.dart';
import '../domain/usecases/user/update_user_profile.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Auth Use Cases
  sl.registerLazySingleton(() => SignUpUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUserUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // User Use Cases
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowersUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));

  // Post Use Cases
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => GetAllPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsByUserIdUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => LikePostUseCase(sl()));
  sl.registerLazySingleton(() => UnlikePostUseCase(sl()));
  sl.registerLazySingleton(() => PostCommentUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));

  // Chat Use Cases
  sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => GetChatRoomsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsReadUseCase(sl()));
  sl.registerLazySingleton(() => GetChatRoomByParticipantsUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PostRepository>(
    () => CachedPostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => CachedChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
      storageDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(
      firestore: sl(),
      storageDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<StorageLocalDataSource>(
    () => StorageLocalDataSourceImpl(
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<HiveLocalDataSource>(
    HiveLocalDataSourceImpl.new,
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(GoogleSignIn.new);
  sl.registerLazySingleton(InternetConnectionChecker.new);
}
