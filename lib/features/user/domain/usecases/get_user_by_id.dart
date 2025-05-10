import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User

import '../../../../core/utils/typedefs.dart';
import '../repositories/user_repository.dart';

/// Use case to get user by ID
class GetUserByIdUseCase {
  /// Constructor
  GetUserByIdUseCase(this.repository);

  /// User repository
  final UserRepository repository;

  /// Execute the use case
  ResultFuture<User> call(String userId) => repository.getUserById(userId);
}
