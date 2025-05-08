import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/user/follow_user.dart';
import '../../../domain/usecases/user/get_all_users.dart';
import '../../../domain/usecases/user/get_followers.dart';
import '../../../domain/usecases/user/get_following.dart';
import '../../../domain/usecases/user/get_user_by_id.dart';
import '../../../domain/usecases/user/search_users.dart';
import '../../../domain/usecases/user/unfollow_user.dart';
import '../../../domain/usecases/user/update_user_profile.dart';

enum UserStatus { initial, loading, loaded, error }

class UserProvider extends ChangeNotifier {
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetAllUsersUseCase _getAllUsersUseCase;
  final SearchUsersUseCase _searchUsersUseCase;
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFollowingUseCase _getFollowingUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  UserProvider({
    required GetUserByIdUseCase getUserByIdUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
    required SearchUsersUseCase searchUsersUseCase,
    required FollowUserUseCase followUserUseCase,
    required UnfollowUserUseCase unfollowUserUseCase,
    required GetFollowersUseCase getFollowersUseCase,
    required GetFollowingUseCase getFollowingUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _getUserByIdUseCase = getUserByIdUseCase,
        _getAllUsersUseCase = getAllUsersUseCase,
        _searchUsersUseCase = searchUsersUseCase,
        _followUserUseCase = followUserUseCase,
        _unfollowUserUseCase = unfollowUserUseCase,
        _getFollowersUseCase = getFollowersUseCase,
        _getFollowingUseCase = getFollowingUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase;

  // State variables
  UserStatus _status = UserStatus.initial;
  User? _selectedUser;
  List<User> _users = [];
  List<User> _followers = [];
  List<User> _following = [];
  List<User> _searchResults = [];
  String _errorMessage = '';
  String _searchQuery = '';

  // Getters
  UserStatus get status => _status;
  User? get selectedUser => _selectedUser;
  List<User> get users => _users;
  List<User> get followers => _followers;
  List<User> get following => _following;
  List<User> get searchResults => _searchResults;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Get a user by ID
  Future<void> getUserById(String userId) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _getUserByIdUseCase(userId);

    result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error getting user: ${failure.message}');
      },
      (user) {
        _selectedUser = user;
        _status = UserStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Get all users
  Future<void> getAllUsers() async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _getAllUsersUseCase();

    result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error getting all users: ${failure.message}');
      },
      (users) {
        _users = users;
        _status = UserStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Search for users
  Future<void> searchUsers(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _searchUsersUseCase(query);

    result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error searching users: ${failure.message}');
      },
      (users) {
        _searchResults = users;
        _status = UserStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Follow a user
  Future<bool> followUser(String userId) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _followUserUseCase(userId);

    return result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error following user: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Update the selected user if it's the one being followed
        if (_selectedUser != null) {
          getUserById(_selectedUser!.uid);
        }
        _status = UserStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Unfollow a user
  Future<bool> unfollowUser(String userId) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _unfollowUserUseCase(userId);

    return result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error unfollowing user: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Update the selected user if it's the one being unfollowed
        if (_selectedUser != null) {
          getUserById(_selectedUser!.uid);
        }
        _status = UserStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Get followers of a user
  Future<void> getFollowers(String userId) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _getFollowersUseCase(userId);

    result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error getting followers: ${failure.message}');
      },
      (followers) {
        _followers = followers;
        _status = UserStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Get users followed by a user
  Future<void> getFollowing(String userId) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _getFollowingUseCase(userId);

    result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error getting following: ${failure.message}');
      },
      (following) {
        _following = following;
        _status = UserStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
  }) async {
    _status = UserStatus.loading;
    notifyListeners();

    final result = await _updateUserProfileUseCase(
      userId: userId,
      userName: userName,
      photoUrl: photoUrl,
      status: status,
    );

    return result.fold(
      (failure) {
        _status = UserStatus.error;
        _errorMessage = failure.message;
        log('Error updating profile: ${failure.message}');
        notifyListeners();
        return false;
      },
      (user) {
        _selectedUser = user;
        _status = UserStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
