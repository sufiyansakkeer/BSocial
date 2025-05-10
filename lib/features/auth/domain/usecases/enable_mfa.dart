import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to enable multi-factor authentication
class EnableMfaUseCase {
  /// Constructor
  EnableMfaUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call() => repository.enableMfa();
}
