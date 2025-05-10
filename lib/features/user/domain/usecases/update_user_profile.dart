import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User

import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to update user profile
class UpdateUserProfileUseCase {
  /// Constructor
  UpdateUserProfileUseCase(this.repository);

  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultFuture<User> call({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  }) =>
      repository.updateUserProfile(
        userId: userId,
        userName: userName,
        photoUrl: photoUrl,
        status: status,
        bio: bio,
      );
}
