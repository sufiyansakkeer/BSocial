import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to send email verification
class SendEmailVerificationUseCase {
  /// Constructor
  SendEmailVerificationUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call() => repository.sendEmailVerification();
}
