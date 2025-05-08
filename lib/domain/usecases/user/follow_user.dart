import '../../../core/utils/typedefs.dart';
import '../../repositories/user_repository.dart';

class FollowUserUseCase {
  final UserRepository repository;

  FollowUserUseCase(this.repository);

  ResultVoid call(String userId) {
    return repository.followUser(userId);
  }
}
