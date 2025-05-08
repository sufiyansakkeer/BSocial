import '../../../core/utils/typedefs.dart';
import '../../repositories/auth_repository.dart';

class SignOutUserUseCase {
  SignOutUserUseCase(this.repository);
  final AuthRepository repository;

  ResultVoid call() => repository.signOutUser();
}
