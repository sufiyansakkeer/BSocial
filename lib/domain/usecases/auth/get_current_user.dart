import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  ResultFuture<User> call() => repository.getCurrentUser();
}
