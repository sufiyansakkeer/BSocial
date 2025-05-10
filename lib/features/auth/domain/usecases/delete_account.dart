import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

/// Use case to delete user account
class DeleteAccountUseCase {
  /// Constructor
  DeleteAccountUseCase(this.repository);
  
  /// Auth repository
  final AuthRepository repository;

  /// Execute the use case
  ResultVoid call({required String password}) => 
      repository.deleteAccount(password: password);
}
