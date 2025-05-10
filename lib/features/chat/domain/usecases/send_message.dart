import '../../../../core/utils/typedefs.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Use case to send a message
class SendMessageUseCase {
  /// Constructor
  SendMessageUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<Message> call({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) =>
      repository.sendMessage(
        roomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
}
