import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../data/datasources/local/storage_local_data_source.dart';
import '../../features/auth/data/datasources/remote/auth_remote_data_source_impl.dart';
import '../../features/auth/data/datasources/remote/mock_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/chat/data/datasources/local/chat_local_data_source.dart';
import '../../features/chat/data/datasources/remote/chat_remote_data_source.dart';
import '../../features/chat/data/datasources/remote/mock_chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/post/data/datasources/local/post_local_data_source.dart';
import '../../features/post/data/datasources/remote/mock_post_remote_data_source.dart';
import '../../features/post/data/datasources/remote/post_remote_data_source.dart';
import '../../features/post/data/repositories/cached_post_repository_impl.dart';
import '../network/network_info.dart';
import '../services/logger_service.dart';

/// Handles dependency initialization and provides repositories
class DependencyInitializer {
  /// Constructor
  DependencyInitializer({
    required LoggerService logger,
    required bool isFirebaseInitialized,
  })  : _logger = logger,
        _isFirebaseInitialized = isFirebaseInitialized;
  final LoggerService _logger;
  final bool _isFirebaseInitialized;

  // Dependencies
  late final NetworkInfoImpl _networkInfo;
  late final AuthRepositoryImpl _authRepository;
  late final CachedPostRepositoryImpl _postRepository;
  late final ChatRepositoryImpl _chatRepository;

  /// Initialize all dependencies
  Future<void> initialize() async {
    // Create network info
    final connectionChecker = InternetConnectionChecker();
    _networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);

    // Initialize repositories based on Firebase availability
    if (_isFirebaseInitialized) {
      _initializeWithFirebase();
    } else {
      _initializeWithoutFirebase();
    }
  }

  /// Initialize repositories with Firebase
  void _initializeWithFirebase() {
    try {
      // Firebase services
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      // Initialize GoogleSignIn with required scopes
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final firebaseStorage = FirebaseStorage.instance;

      // Storage DataSource
      final storageDataSource =
          StorageLocalDataSourceImpl(storage: firebaseStorage);

      // Auth feature
      final authRemoteDataSource = AuthRemoteDataSourceImpl(
        auth: auth,
        firestore: firestore,
        googleSignIn: googleSignIn,
        storageDataSource: storageDataSource,
      );
      _authRepository = AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        networkInfo: _networkInfo,
      );

      // Post feature
      final postLocalDataSource = PostLocalDataSourceImpl();
      final postRemoteDataSource = PostRemoteDataSourceImpl(
        firestore: firestore,
        storageDataSource: storageDataSource,
      );
      _postRepository = CachedPostRepositoryImpl(
        remoteDataSource: postRemoteDataSource,
        localDataSource: postLocalDataSource,
      );

      // Chat feature
      final chatLocalDataSource = ChatLocalDataSourceImpl();
      final chatRemoteDataSource = ChatRemoteDataSourceImpl(
        firestore: firestore,
      );
      _chatRepository = ChatRepositoryImpl(
        remoteDataSource: chatRemoteDataSource,
        localDataSource: chatLocalDataSource,
        networkInfo: _networkInfo,
      );

      _logger.i('Firebase services initialized successfully');
    } on Exception catch (e) {
      _logger.e('Error initializing Firebase services: $e');
      // Fall back to offline mode if Firebase services initialization fails
      _initializeWithoutFirebase();
    }
  }

  /// Initialize repositories without Firebase (offline mode)
  void _initializeWithoutFirebase() {
    _logger.w('Using offline mode due to Firebase initialization failure');

    // Auth feature
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: MockAuthRemoteDataSource(),
      networkInfo: _networkInfo,
    );

    // Post feature
    final postLocalDataSource = PostLocalDataSourceImpl();
    _postRepository = CachedPostRepositoryImpl(
      remoteDataSource: MockPostRemoteDataSourceImpl(),
      localDataSource: postLocalDataSource,
    );

    // Chat feature
    final chatLocalDataSource = ChatLocalDataSourceImpl();
    _chatRepository = ChatRepositoryImpl(
      remoteDataSource: MockChatRemoteDataSourceImpl(),
      localDataSource: chatLocalDataSource,
      networkInfo: _networkInfo,
    );
  }

  // Getters for repositories
  AuthRepositoryImpl get authRepository => _authRepository;
  CachedPostRepositoryImpl get postRepository => _postRepository;
  ChatRepositoryImpl get chatRepository => _chatRepository;
}
