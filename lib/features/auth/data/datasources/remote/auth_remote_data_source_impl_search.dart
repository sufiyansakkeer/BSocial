import 'dart:developer';


import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/user.dart';
// Import the interface, but hide AuthRemoteDataSourceImpl if it's also exported
// from there
import 'auth_remote_data_source.dart' hide AuthRemoteDataSourceImpl;
// Import the concrete implementation
import 'auth_remote_data_source_impl.dart';

/// Implementation of the search functionality for [AuthRemoteDataSource]
extension SearchFunctionality on AuthRemoteDataSourceImpl {
  /// Search users by username or email
  // Note: The @override here might be problematic if searchUsers is not in the
  // AuthRemoteDataSource interface and is intended to be a new method provided
  // by the extension. If it's meant to implement an interface method,
  // AuthRemoteDataSourceImpl should implement AuthRemoteDataSource. For now,
  // assuming it's an extension method that might shadow or implement an
  // interface method.
  Future<List<User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // First search by username
      final usernameQuerySnapshot =
          await firestore // Use public getter from AuthRemoteDataSourceImpl
              .collection(AppConstants.usersCollection)
              .where('userName', isGreaterThanOrEqualTo: query)
              .where('userName', isLessThanOrEqualTo: '$query\uf8ff')
              .get();

      // Then search by email
      final emailQuerySnapshot =
          await firestore // Use public getter from AuthRemoteDataSourceImpl
              .collection(AppConstants.usersCollection)
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThanOrEqualTo: '$query\uf8ff')
              .get();

      // Combine results and remove duplicates
      final uniqueUsers = <String, User>{};

      // Process username results
      for (final doc in usernameQuerySnapshot.docs) {
        final data = doc.data();
        uniqueUsers[doc.id] = User(
          uid: doc.id,
          email: data['email'] as String,
          userName: data['userName'] as String,
          photoUrl: data['photoUrl'] as String,
          bio: data['bio'] as String? ?? '',
          followers: List<String>.from(data['followers'] as List? ?? []),
          following: List<String>.from(data['following'] as List? ?? []),
          status: data['status'] as String? ?? 'Available',
          isMfaEnabled: data['isMfaEnabled'] as bool? ?? false,
          isEmailVerified: data['isEmailVerified'] as bool? ?? false,
        );
      }

      // Process email results
      for (final doc in emailQuerySnapshot.docs) {
        if (!uniqueUsers.containsKey(doc.id)) {
          final data = doc.data();
          uniqueUsers[doc.id] = User(
            uid: doc.id,
            email: data['email'] as String,
            userName: data['userName'] as String,
            photoUrl: data['photoUrl'] as String,
            bio: data['bio'] as String? ?? '',
            followers: List<String>.from(data['followers'] as List? ?? []),
            following: List<String>.from(data['following'] as List? ?? []),
            status: data['status'] as String? ?? 'Available',
            isMfaEnabled: data['isMfaEnabled'] as bool? ?? false,
            isEmailVerified: data['isEmailVerified'] as bool? ?? false,
          );
        }
      }

      return uniqueUsers.values.toList();
    } catch (e) {
      log('Search users error: $e', name: 'searchUsers');
      // This relies on _handleException being accessible or re-throwing
      // AuthException For now, re-throwing AuthException directly as per
      // previous structure.
      throw AuthException(message: 'Failed to search users: ${e.toString()}');
    }
  }
}
