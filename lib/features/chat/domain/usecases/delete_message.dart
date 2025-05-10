import '../../../../core/utils/typedefs.dart';
import '../repositories/chat_repository.dart';

/// Use case to delete a message
class DeleteMessageUseCase {
  /// Constructor
  DeleteMessageUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultVoid call(String messageId, String roomId) => 
      repository.deleteMessage(messageId, roomId);
}
