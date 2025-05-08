import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetFollowersUseCase {
  final UserRepository repository;

  GetFollowersUseCase(this.repository);

  ResultFuture<List<User>> call(String userId) {
    return repository.getFollowers(userId);
  }
}
