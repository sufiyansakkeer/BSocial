import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to login a user
class LoginUserUseCase {
  /// Constructor
  LoginUserUseCase(this.repository);

  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call({
    required String email,
    required String password,
  }) =>
      repository.loginUser(
        email: email,
        password: password,
      );
}
