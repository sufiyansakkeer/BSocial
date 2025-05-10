import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to get the current authenticated user
class GetCurrentUserUseCase {
  /// Constructor
  GetCurrentUserUseCase(this.repository);

  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call() => repository.getCurrentUser();
}
