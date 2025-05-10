import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to sign in with Google
class SignInWithGoogleUseCase {
  /// Constructor
  SignInWithGoogleUseCase(this.repository);

  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call() => repository.signInWithGoogle();
}
