import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  ResultFuture<User> call({
    required String email,
    required String password,
  }) {
    return repository.loginUser(
      email: email,
      password: password,
    );
  }
}
