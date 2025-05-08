import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  ResultFuture<List<User>> call() {
    return repository.getAllUsers();
  }
}
