import '../../../../core/utils/typedefs.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// Use case to get a chat room by ID
class GetChatRoomByIdUseCase {
  /// Constructor
  GetChatRoomByIdUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<ChatRoom> call(String roomId) => 
      repository.getChatRoomById(roomId);
}
