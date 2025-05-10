import '../../../../core/utils/typedefs.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';

/// Use case to get a user profile
class GetUserProfileUseCase {
  /// Constructor
  GetUserProfileUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<User> call(String userId) => repository.getUserById(userId);
}
