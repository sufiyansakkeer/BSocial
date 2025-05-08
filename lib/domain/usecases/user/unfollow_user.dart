import '../../../core/utils/typedefs.dart';
import '../../repositories/user_repository.dart';

class UnfollowUserUseCase {
  final UserRepository repository;

  UnfollowUserUseCase(this.repository);

  ResultVoid call(String userId) {
    return repository.unfollowUser(userId);
  }
}
