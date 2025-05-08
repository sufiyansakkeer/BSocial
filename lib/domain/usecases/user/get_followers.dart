import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetFollowersUseCase {
  GetFollowersUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<List<User>> call(String userId) =>
      repository.getFollowers(userId);
}
