import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class SearchUsersUseCase {
  final UserRepository repository;

  SearchUsersUseCase(this.repository);

  ResultFuture<List<User>> call(String query) {
    return repository.searchUsers(query);
  }
}
