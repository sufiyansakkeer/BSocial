import 'dart:typed_data';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to sign up a new user
class SignUpUserUseCase {
  /// Constructor
  SignUpUserUseCase(this.repository);

  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call({
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
