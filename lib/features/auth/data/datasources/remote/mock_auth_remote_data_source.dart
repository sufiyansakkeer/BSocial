import 'dart:typed_data';

import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_auth.dart';
import '../../models/user_auth_model.dart';
import 'auth_remote_data_source.dart';

/// Mock implementation of [AuthRemoteDataSource] for offline mode
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final List<UserAuthModel> _users = [
    const UserAuthModel(
      uid: 'user1',
      email: 'user1@example.com',
      userName: 'User One',
      photoUrl: 'https://via.placeholder.com/150',
      followers: [],
      following: [],
      status: 'Available',
    ),
    const UserAuthModel(
      uid: 'user2',
      email: 'user2@example.com',
      userName: 'User Two',
      photoUrl: 'https://via.placeholder.com/150',
      followers: ['user1'],
      following: [],
      status: 'Busy',
    ),
  ];

  UserAuthModel? _currentUser;

  @override
  Future<UserAuthModel> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser!;
    }
    throw AuthException(message: 'No user is currently logged in');
  }

  @override
  Future<bool> isUserAuthenticated() async => _currentUser != null;

  @override
  Future<UserAuthModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = _users.firstWhere((user) => user.email == email);
      _currentUser = user;
      return user;
    } on Exception {
      throw AuthException(message: 'Invalid email or password');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (!_users.any((user) => user.email == email)) {
      throw AuthException(message: 'Email not found');
    }
  }

  @override
  Future<UserAuthModel> signInWithGoogle() async {
    final user = _users.first;
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOutUser() async {
    _currentUser = null;
  }

  @override
  Future<UserAuthModel> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) async {
    if (_users.any((user) => user.email == email)) {
      throw AuthException(message: 'Email already in use');
    }

    if (_users.any((user) => user.userName == userName)) {
      throw AuthException(message: 'Username already in use');
    }

    final newUser = UserAuthModel(
      uid: 'user${_users.length + 1}',
      email: email,
      userName: userName,
      photoUrl: 'https://via.placeholder.com/150',
      followers: const [],
      following: const [],
      status: 'Available',
    );

    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }

    final index = _users.indexWhere((user) => user.uid == _currentUser!.uid);
    if (index != -1) {
      _users.removeAt(index);
      _currentUser = null;
    }
  }

  @override
  Future<void> disableMfa({required String password}) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
  }

  @override
  Future<void> enableMfa() async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
  }

  @override
  Future<UserRole> getUserRole() async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
    return UserRole.user;
  }

  @override
  Future<bool> hasPermission(String permission) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
    return false;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
  }

  @override
  Future<UserAuthModel> updateUserProfile({
    String? userName,
    Uint8List? profileImage,
    String? status,
  }) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }

    final index = _users.indexWhere((user) => user.uid == _currentUser!.uid);
    if (index == -1) {
      throw AuthException(message: 'User not found');
    }

    _users[index] = UserAuthModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      userName: userName ?? _currentUser!.userName,
      photoUrl: _currentUser!.photoUrl,
      followers: _currentUser!.followers,
      following: _currentUser!.following,
      status: status ?? _currentUser!.status,
    );

    _currentUser = _users[index];
    return _currentUser!;
  }

  @override
  Future<void> verifyEmail(String code) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
  }

  @override
  Future<UserAuthModel> verifyMfaCode(String code) async {
    if (_currentUser == null) {
      throw AuthException(message: 'No user is currently logged in');
    }
    return _currentUser!;
  }

  @override
  Future<User> getUserById(String userId) async {
    final userIndex = _users.indexWhere((user) => user.uid == userId);

    if (userIndex == -1) {
      throw AuthException(message: 'User not found');
    }

    final userAuth = _users[userIndex];

    return User(
      uid: userAuth.uid,
      email: userAuth.email,
      userName: userAuth.userName,
      photoUrl: userAuth.photoUrl,
      followers: userAuth.followers,
      following: userAuth.following,
      status: userAuth.status,
      isEmailVerified: true,
    );
  }

  @override
  Future<User> updateUser({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  }) async {
    try {
      final index = _users.indexWhere((user) => user.uid == userId);
      if (index == -1) {
        throw AuthException(message: 'User not found');
      }

      final user = _users[index];

      _users[index] = UserAuthModel(
        uid: user.uid,
        email: user.email,
        userName: userName ?? user.userName,
        photoUrl: user.photoUrl,
        followers: user.followers,
        following: user.following,
        status: user.status,
      );

      if (_currentUser?.uid == userId) {
        _currentUser = _users[index];
      }

      return User(
        uid: _users[index].uid,
        email: _users[index].email,
        userName: _users[index].userName,
        photoUrl: _users[index].photoUrl,
        bio: bio ?? '',
        followers: _users[index].followers,
        following: _users[index].following,
        status: _users[index].status,
        isEmailVerified: true,
      );
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException(message: 'Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final lowercaseQuery = query.toLowerCase();

    return _users
        .where((user) =>
            user.userName.toLowerCase().contains(lowercaseQuery) ||
            user.email.toLowerCase().contains(lowercaseQuery))
        .map((userAuth) => User(
              uid: userAuth.uid,
              email: userAuth.email,
              userName: userAuth.userName,
              photoUrl: userAuth.photoUrl,
              followers: userAuth.followers,
              following: userAuth.following,
              status: userAuth.status,
              isEmailVerified: true,
            ))
        .toList();
  }
}
