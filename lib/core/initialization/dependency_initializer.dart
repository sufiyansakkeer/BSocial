import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../data/datasources/local/hive_local_data_source.dart';
import '../../data/datasources/local/storage_local_data_source.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/mock_auth_remote_data_source.dart';
import '../../data/datasources/remote/mock_post_remote_data_source.dart';
import '../../data/datasources/remote/mock_storage_local_data_source.dart';
import '../../data/datasources/remote/mock_user_remote_data_source.dart';
import '../../data/datasources/remote/post_remote_data_source.dart';
import '../../data/datasources/remote/user_remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cached_post_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../network/network_info.dart';
import '../services/logger_service.dart';

/// Handles dependency initialization and provides repositories
class DependencyInitializer {
  DependencyInitializer({
    required LoggerService logger,
    required bool isFirebaseInitialized,
  })  : _logger = logger,
        _isFirebaseInitialized = isFirebaseInitialized;
  final LoggerService _logger;
  final bool _isFirebaseInitialized;

  // Dependencies
  late final NetworkInfoImpl _networkInfo;
  late final HiveLocalDataSourceImpl _localDataSource;
  late final AuthRepositoryImpl _authRepository;
  late final CachedPostRepositoryImpl _postRepository;
  late final UserRepositoryImpl _userRepository;
  late final StorageRepositoryImpl _storageRepository;

  /// Initialize all dependencies
  Future<void> initialize() async {
    // Create network info
    final connectionChecker = InternetConnectionChecker();
    _networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);

    // Initialize local data source
    _localDataSource = HiveLocalDataSourceImpl();

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
      final storage = FirebaseStorage.instance;
      final googleSignIn = GoogleSignIn();

      // Data sources that depend on Firebase
      final storageDataSource = StorageLocalDataSourceImpl(storage: storage);
      final authRemoteDataSource = AuthRemoteDataSourceImpl(
        auth: auth,
        firestore: firestore,
        googleSignIn: googleSignIn,
        storageDataSource: storageDataSource,
      );
      final postRemoteDataSource = PostRemoteDataSourceImpl(
        firestore: firestore,
        storageDataSource: storageDataSource,
      );
      final userRemoteDataSource = UserRemoteDataSourceImpl(
        firestore: firestore,
        auth: auth,
      );

      // Create repositories with Firebase-dependent data sources
      _storageRepository = StorageRepositoryImpl(
        storageDataSource: storageDataSource,
        networkInfo: _networkInfo,
      );

      _authRepository = AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        networkInfo: _networkInfo,
      );

      _postRepository = CachedPostRepositoryImpl(
        remoteDataSource: postRemoteDataSource,
        localDataSource: _localDataSource,
        networkInfo: _networkInfo,
      );

      _userRepository = UserRepositoryImpl(
        remoteDataSource: userRemoteDataSource,
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

    // Create repositories with mock data sources for offline mode
    final mockStorageDataSource = MockStorageLocalDataSource();

    _storageRepository = StorageRepositoryImpl(
      storageDataSource: mockStorageDataSource,
      networkInfo: _networkInfo,
    );

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: MockAuthRemoteDataSource(),
      networkInfo: _networkInfo,
    );

    _postRepository = CachedPostRepositoryImpl(
      remoteDataSource: MockPostRemoteDataSource(),
      localDataSource: _localDataSource,
      networkInfo: _networkInfo,
    );

    _userRepository = UserRepositoryImpl(
      remoteDataSource: MockUserRemoteDataSource(),
      networkInfo: _networkInfo,
    );
  }

  // Getters for repositories
  AuthRepositoryImpl get authRepository => _authRepository;
  CachedPostRepositoryImpl get postRepository => _postRepository;
  UserRepository get userRepository => _userRepository;
  StorageRepository get storageRepository => _storageRepository;
}
