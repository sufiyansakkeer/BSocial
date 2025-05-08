import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this.repository);
  final AuthRepository repository;

  ResultFuture<User> call() => repository.signInWithGoogle();
}
