import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetUserByIdUseCase {
  GetUserByIdUseCase(this.repository);
  final UserRepository repository;

  ResultFuture<User> call(String userId) => repository.getUserById(userId);
}
