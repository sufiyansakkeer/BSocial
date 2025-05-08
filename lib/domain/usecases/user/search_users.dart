import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class SearchUsersUseCase {
  SearchUsersUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<List<User>> call(String query) => repository.searchUsers(query);
}
