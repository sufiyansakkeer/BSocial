import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User

import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to search users
class SearchUsersUseCase {
  /// Constructor
  SearchUsersUseCase(this.repository);

  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultFuture<List<User>> call(String query) => repository.searchUsers(query);
}
