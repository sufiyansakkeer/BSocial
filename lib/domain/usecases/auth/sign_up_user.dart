import 'dart:typed_data';
import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignUpUserUseCase {
  SignUpUserUseCase(this.repository);
  final AuthRepository repository;

  ResultFuture<User> call({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) =>
      repository.signUpUser(
        userName: userName,
        email: email,
        password: password,
        file: file,
      );
}
