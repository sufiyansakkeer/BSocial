import '../../../../core/utils/typedefs.dart';
import '../repositories/chat_repository.dart';

/// Use case to mark messages as read
class MarkMessagesAsReadUseCase {
  /// Constructor
  MarkMessagesAsReadUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultVoid call(String roomId, String userId) => 
      repository.markMessagesAsRead(roomId, userId);
}
