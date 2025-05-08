import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetFollowingUseCase {
  GetFollowingUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<List<User>> call(String userId) =>
      repository.getFollowing(userId);
}
