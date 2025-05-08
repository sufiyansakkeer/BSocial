import '../../../core/utils/typedefs.dart';
import '../../repositories/auth_repository.dart';

class SignOutUserUseCase {
  final AuthRepository repository;

  SignOutUserUseCase(this.repository);

  ResultVoid call() {
    return repository.signOutUser();
  }
}
