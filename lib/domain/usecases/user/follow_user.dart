import '../../../core/utils/typedefs.dart';
import '../../repositories/user_repository.dart';

class FollowUserUseCase {
  FollowUserUseCase(this.repository);
  final UserRepository repository;

  ResultVoid call(String userId) => repository.followUser(userId);
}
