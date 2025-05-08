import '../../../core/utils/typedefs.dart';
import '../../entities/message.dart';
import '../../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  ResultFuture<List<Message>> call(String roomId) {
    return repository.getMessages(roomId);
  }
}
