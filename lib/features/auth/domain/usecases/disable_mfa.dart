import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to disable multi-factor authentication
class DisableMfaUseCase {
  /// Constructor
  DisableMfaUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call({required String password}) => 
      repository.disableMfa(password: password);
}
