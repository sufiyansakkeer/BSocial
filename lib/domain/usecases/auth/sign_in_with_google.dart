import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  ResultFuture<User> call() {
    return repository.signInWithGoogle();
  }
}
