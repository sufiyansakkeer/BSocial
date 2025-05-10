import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to get user role
class GetUserRoleUseCase {
  /// Constructor
  GetUserRoleUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserRole> call() => repository.getUserRole();
}
