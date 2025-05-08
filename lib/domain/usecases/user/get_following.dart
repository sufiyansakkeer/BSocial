import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetFollowingUseCase {
  final UserRepository repository;

  GetFollowingUseCase(this.repository);

  ResultFuture<List<User>> call(String userId) {
    return repository.getFollowing(userId);
  }
}
