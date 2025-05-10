import 'dart:typed_data';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to update user profile
class UpdateUserProfileUseCase {
  /// Constructor
  UpdateUserProfileUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call({
    String? userName,
    Uint8List? profileImage,
    String? status,
  }) =>
      repository.updateUserProfile(
        userName: userName,
        profileImage: profileImage,
        status: status,
      );
}
