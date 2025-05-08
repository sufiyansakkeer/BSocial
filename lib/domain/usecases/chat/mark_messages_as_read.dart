import '../../../core/utils/typedefs.dart';
import '../../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  MarkMessagesAsReadUseCase(this.repository);
  final ChatRepository repository;

  ResultVoid call(String roomId, String userId) =>
      repository.markMessagesAsRead(roomId, userId);
}
