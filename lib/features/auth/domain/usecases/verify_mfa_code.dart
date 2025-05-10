import '../../../../core/utils/typedefs.dart';
import '../entities/user_auth.dart';
import '../repositories/auth_repository.dart';

/// Use case to verify multi-factor authentication code
class VerifyMfaCodeUseCase {
  /// Constructor
  VerifyMfaCodeUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultFuture<UserAuth> call(String code) => repository.verifyMfaCode(code);
}
