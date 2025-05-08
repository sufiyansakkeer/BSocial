import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  ResultFuture<User> call() {
    return repository.getCurrentUser();
  }
}
