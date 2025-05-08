import '../../../core/utils/typedefs.dart';
import '../../entities/message.dart';
import '../../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  ResultFuture<Message> call({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return repository.sendMessage(
      roomId: roomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
  }
}
