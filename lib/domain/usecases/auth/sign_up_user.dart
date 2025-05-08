import 'dart:typed_data';
import '../../../core/utils/typedefs.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignUpUserUseCase {
  final AuthRepository repository;

  SignUpUserUseCase(this.repository);

  ResultFuture<User> call({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) {
    return repository.signUpUser(
      userName: userName,
      email: email,
      password: password,
      file: file,
    );
  }
}
