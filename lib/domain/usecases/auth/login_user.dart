import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUserUseCase {
  LoginUserUseCase(this.repository);
  final AuthRepository repository;

  ResultFuture<User> call({
    required String email,
    required String password,
  }) =>
      repository.loginUser(
        email: email,
        password: password,
      );
}
