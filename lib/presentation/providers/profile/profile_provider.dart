import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/image_utils.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/post/get_posts_by_user_id.dart';
import '../../../domain/usecases/user/get_followers.dart';
import '../../../domain/usecases/user/get_following.dart';
import '../../../domain/usecases/user/get_user_by_id.dart';
import '../../../domain/usecases/user/update_user_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetPostsByUserIdUseCase _getPostsByUserIdUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFollowingUseCase _getFollowingUseCase;

  ProfileProvider({
    required GetUserByIdUseCase getUserByIdUseCase,
    required GetPostsByUserIdUseCase getPostsByUserIdUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required GetFollowersUseCase getFollowersUseCase,
    required GetFollowingUseCase getFollowingUseCase,
  })  : _getUserByIdUseCase = getUserByIdUseCase,
        _getPostsByUserIdUseCase = getPostsByUserIdUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _getFollowersUseCase = getFollowersUseCase,
        _getFollowingUseCase = getFollowingUseCase;

  // State variables
  ProfileStatus _status = ProfileStatus.initial;
  User? _user;
  List<Post> _userPosts = [];
  final List<User> _followers = [];
  final List<User> _following = [];
  String _errorMessage = '';
  Uint8List? _profileImage;

  // Getters
  ProfileStatus get status => _status;
  User? get user => _user;
  List<Post> get userPosts => _userPosts;
  List<User> get followers => _followers;
  List<User> get following => _following;
  String get errorMessage => _errorMessage;
  Uint8List? get profileImage => _profileImage;

  // Text controllers for profile editing
  final TextEditingController usernameController = TextEditingController();

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    // Get user data
    final userResult = await _getUserByIdUseCase(userId);

    userResult.fold(
      (failure) {
        _status = ProfileStatus.error;
        _errorMessage = failure.message;
        log('Error loading user profile: ${failure.message}');
        notifyListeners();
      },
      (user) async {
        _user = user;

        // Get user posts
        final postsResult = await _getPostsByUserIdUseCase(userId);

        postsResult.fold(
          (failure) {
            log('Failed to load posts: ${failure.message}');
            _userPosts = [];
          },
          (posts) {
            _userPosts = posts;
          },
        );

        // Get followers
        final followersResult = await _getFollowersUseCase(userId);

        followersResult.fold(
          (failure) {
            log('Failed to load followers: ${failure.message}');
            _followers.clear();
          },
          (followers) {
            _followers.clear();
            _followers.addAll(followers);
          },
        );

        // Get following
        final followingResult = await _getFollowingUseCase(userId);

        followingResult.fold(
          (failure) {
            log('Failed to load following: ${failure.message}');
            _following.clear();
          },
          (following) {
            _following.clear();
            _following.addAll(following);
          },
        );

        _status = ProfileStatus.loaded;
        notifyListeners();
      },
    );
  }

  // Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? username,
    String? photoUrl,
    String? status,
  }) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    // If we have a profile image in memory but no photoUrl provided,
    // we would need to upload it first
    // For now, we'll just use the provided photoUrl
    // In a real implementation, you would:
    // 1. Upload the image using a storage use case
    // 2. Get the URL from the upload result
    // 3. Pass that URL to the update profile use case

    final result = await _updateUserProfileUseCase(
      userId: userId,
      userName: username,
      photoUrl: photoUrl,
      status: status,
    );

    return result.fold(
      (failure) {
        _status = ProfileStatus.error;
        _errorMessage = failure.message;
        log('Error updating profile: ${failure.message}');
        notifyListeners();
        return false;
      },
      (updatedUser) {
        _user = updatedUser;
        _profileImage = null; // Clear the profile image after update
        _status = ProfileStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Initialize edit form with current user data
  void initEditForm() {
    if (_user != null) {
      usernameController.text = _user!.userName;
    }
  }

  // Select profile image
  Future<void> selectProfileImage() async {
    final image = await ImageUtils.pickImage(ImageSource.gallery);
    if (image != null) {
      _profileImage = image;
      notifyListeners();
    }
  }

  // Clear form fields
  void clearFormFields() {
    usernameController.clear();
    _profileImage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }
}
