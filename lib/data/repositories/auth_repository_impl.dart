import 'dart:typed_data';
import '../../core/repositories/base_repository.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;

  @override
  ResultFuture<User> getCurrentUser() => handleRemoteCall(
        call: remoteDataSource.getCurrentUser,
        errorMessage: 'Failed to get current user',
      );

  @override
  Future<bool> isUserAuthenticated() async =>
      remoteDataSource.isUserAuthenticated();

  @override
  ResultFuture<User> loginUser({
    required String email,
    required String password,
  }) =>
      handleRemoteCall(
        call: () => remoteDataSource.loginUser(
          email: email,
          password: password,
        ),
        errorMessage: 'Failed to login',
      );

  @override
  ResultVoid resetPassword(String email) => handleRemoteCall(
        call: () => remoteDataSource.resetPassword(email),
        errorMessage: 'Failed to reset password',
      );

  @override
  ResultFuture<User> signInWithGoogle() => handleRemoteCall(
        call: remoteDataSource.signInWithGoogle,
        errorMessage: 'Failed to sign in with Google',
      );

  @override
  ResultVoid signOutUser() => handleRemoteCall(
        call: remoteDataSource.signOutUser,
        errorMessage: 'Failed to sign out',
      );

  @override
  ResultFuture<User> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) =>
      handleRemoteCall(
        call: () => remoteDataSource.signUpUser(
          userName: userName,
          email: email,
          password: password,
          file: file,
        ),
        errorMessage: 'Failed to sign up',
      );
}
