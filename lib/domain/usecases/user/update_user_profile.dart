import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUserProfileUseCase {
  UpdateUserProfileUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<User> call({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
  }) =>
      repository.updateUserProfile(
        userId: userId,
        userName: userName,
        photoUrl: photoUrl,
        status: status,
      );
}
