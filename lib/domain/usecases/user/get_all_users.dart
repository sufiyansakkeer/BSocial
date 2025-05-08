import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetAllUsersUseCase {
  GetAllUsersUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<List<User>> call() => repository.getAllUsers();
}
