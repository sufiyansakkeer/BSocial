import 'dart:typed_data';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

/// Implementation of [AuthRepository]
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  /// Constructor
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  /// Remote data source for authentication operations
  final AuthRemoteDataSource remoteDataSource;

  @override
  ResultFuture<UserAuth> getCurrentUser() => handleRemoteCall(
        call: remoteDataSource.getCurrentUser,
        errorMessage: 'Failed to get current user',
      );

  @override
  Future<bool> isUserAuthenticated() async =>
      remoteDataSource.isUserAuthenticated();

  @override
  ResultFuture<UserAuth> loginUser({
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
  ResultFuture<UserAuth> signInWithGoogle() => handleRemoteCall(
        call: remoteDataSource.signInWithGoogle,
        errorMessage: 'Failed to sign in with Google',
      );

  @override
  ResultVoid signOutUser() => handleRemoteCall(
        call: remoteDataSource.signOutUser,
        errorMessage: 'Failed to sign out',
      );

  @override
  ResultFuture<UserAuth> signUpUser({
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

  @override
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      handleRemoteCall(
        call: () => remoteDataSource.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
        errorMessage: 'Failed to change password',
      );

  @override
  ResultVoid deleteAccount({required String password}) => handleRemoteCall(
        call: () => remoteDataSource.deleteAccount(password: password),
        errorMessage: 'Failed to delete account',
      );

  @override
  ResultVoid disableMfa({required String password}) => handleRemoteCall(
        call: () => remoteDataSource.disableMfa(password: password),
        errorMessage: 'Failed to disable MFA',
      );

  @override
  ResultVoid enableMfa() => handleRemoteCall(
        call: remoteDataSource.enableMfa,
        errorMessage: 'Failed to enable MFA',
      );

  @override
  ResultFuture<UserRole> getUserRole() => handleRemoteCall(
        call: remoteDataSource.getUserRole,
        errorMessage: 'Failed to get user role',
      );

  @override
  ResultFuture<bool> hasPermission(String permission) => handleRemoteCall(
        call: () => remoteDataSource.hasPermission(permission),
        errorMessage: 'Failed to check permission',
      );

  @override
  ResultVoid sendEmailVerification() => handleRemoteCall(
        call: remoteDataSource.sendEmailVerification,
        errorMessage: 'Failed to send email verification',
      );

  @override
  ResultFuture<UserAuth> updateUserProfile({
    String? userName,
    Uint8List? profileImage,
    String? status,
  }) =>
      handleRemoteCall(
        call: () => remoteDataSource.updateUserProfile(
          userName: userName,
          profileImage: profileImage,
          status: status,
        ),
        errorMessage: 'Failed to update profile',
      );

  @override
  ResultVoid verifyEmail(String code) => handleRemoteCall(
        call: () => remoteDataSource.verifyEmail(code),
        errorMessage: 'Failed to verify email',
      );

  @override
  ResultFuture<UserAuth> verifyMfaCode(String code) => handleRemoteCall(
        call: () => remoteDataSource.verifyMfaCode(code),
        errorMessage: 'Failed to verify MFA code',
      );

  @override
  ResultFuture<User> getUserById(String userId) => handleRemoteCall(
        call: () => remoteDataSource.getUserById(userId),
        errorMessage: 'Failed to get user by ID',
      );

  @override
  ResultFuture<User> updateUser({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  }) =>
      handleRemoteCall(
        call: () => remoteDataSource.updateUser(
          userId: userId,
          userName: userName,
          bio: bio,
          profilePic: profilePic,
        ),
        errorMessage: 'Failed to update user',
      );

  @override
  ResultFuture<List<User>> searchUsers(String query) => handleRemoteCall(
        call: () => remoteDataSource.searchUsers(query),
        errorMessage: 'Failed to search users',
      );
}
