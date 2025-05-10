import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to follow a user
class FollowUserUseCase {
  /// Constructor
  FollowUserUseCase(this.repository);
  
  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultVoid call(String userId) => repository.followUser(userId);
}
