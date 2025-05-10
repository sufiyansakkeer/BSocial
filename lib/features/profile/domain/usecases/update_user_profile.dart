import 'dart:typed_data';

import '../../../../core/utils/typedefs.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';

/// Use case to update a user profile
class UpdateUserProfileUseCase {
  /// Constructor
  UpdateUserProfileUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<User> call({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  }) =>
      repository.updateUser(
        userId: userId,
        userName: userName,
        bio: bio,
        profilePic: profilePic,
      );
}
