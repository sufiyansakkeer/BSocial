import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to change user password
class ChangePasswordUseCase {
  /// Constructor
  ChangePasswordUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call({
    required String currentPassword,
    required String newPassword,
  }) =>
      repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
