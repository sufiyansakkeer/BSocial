import '../../../core/utils/typedefs.dart';
import '../../entities/message.dart';
import '../../repositories/chat_repository.dart';

class GetMessagesUseCase {
  GetMessagesUseCase(this.repository);
  final ChatRepository repository;

  ResultFuture<List<Message>> call(String roomId) =>
      repository.getMessages(roomId);
}
