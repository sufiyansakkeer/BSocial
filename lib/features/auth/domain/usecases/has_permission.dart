import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to check if user has specific permission
class HasPermissionUseCase {
  /// Constructor
  HasPermissionUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<bool> call(String permission) => 
      repository.hasPermission(permission);
}
