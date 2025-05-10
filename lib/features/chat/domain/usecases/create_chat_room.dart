import '../../../../core/utils/typedefs.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// Use case to create a new chat room
class CreateChatRoomUseCase {
  /// Constructor
  CreateChatRoomUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<ChatRoom> call(List<String> participants) => 
      repository.createChatRoom(participants);
}
