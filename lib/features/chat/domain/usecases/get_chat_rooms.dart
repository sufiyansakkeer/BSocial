import '../../../../core/utils/typedefs.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// Use case to get all chat rooms for a user
class GetChatRoomsUseCase {
  /// Constructor
  GetChatRoomsUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<List<ChatRoom>> call(String userId) => 
      repository.getChatRooms(userId);
}
