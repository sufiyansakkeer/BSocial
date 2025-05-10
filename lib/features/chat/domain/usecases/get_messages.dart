import '../../../../core/utils/typedefs.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Use case to get messages for a chat room
class GetMessagesUseCase {
  /// Constructor
  GetMessagesUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<List<Message>> call(String roomId) => 
      repository.getMessages(roomId);
}
