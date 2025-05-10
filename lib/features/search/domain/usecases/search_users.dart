import '../../../../core/utils/typedefs.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';

/// Use case to search for users
class SearchUsersUseCase {
  /// Constructor
  SearchUsersUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<List<User>> call(String searchQuery) => 
      repository.searchUsers(searchQuery);
}
