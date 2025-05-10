import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to verify email with code
class VerifyEmailUseCase {
  /// Constructor
  VerifyEmailUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call(String code) => repository.verifyEmail(code);
}
