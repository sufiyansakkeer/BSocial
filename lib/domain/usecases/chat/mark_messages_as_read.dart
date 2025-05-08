import '../../../core/utils/typedefs.dart';
import '../../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  ResultVoid call(String roomId, String userId) {
    return repository.markMessagesAsRead(roomId, userId);
  }
}
