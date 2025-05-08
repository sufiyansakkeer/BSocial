import '../../../core/utils/typedefs.dart';
import '../../repositories/user_repository.dart';

class UnfollowUserUseCase {
  UnfollowUserUseCase(this.repository);
  final UserRepository repository;

  ResultVoid call(String userId) => repository.unfollowUser(userId);
}
