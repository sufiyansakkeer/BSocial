import '../../../core/utils/typedefs.dart';
import '../../../features/chat/domain/entities/message.dart';
import '../../repositories/chat_repository.dart';

class GetMessagesUseCase {
  GetMessagesUseCase(this.repository);
  final ChatRepository repository;

  ResultFuture<List<Message>> call(String roomId) =>
      repository.getMessages(roomId);
}
