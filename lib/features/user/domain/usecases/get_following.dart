import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User

import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to get users followed by a user
class GetFollowingUseCase {
  /// Constructor
  GetFollowingUseCase(this.repository);

  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultFuture<List<User>> call(String userId) => repository.getFollowing(userId);
}
