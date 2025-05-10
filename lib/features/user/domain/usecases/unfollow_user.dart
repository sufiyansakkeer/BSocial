import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to unfollow a user
class UnfollowUserUseCase {
  /// Constructor
  UnfollowUserUseCase(this.repository);
  
  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultVoid call(String userId) => repository.unfollowUser(userId);
}
