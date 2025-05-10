import '../../../../core/utils/typedefs.dart';
import '../repositories/chat_repository.dart';

/// Use case to delete a chat room
class DeleteChatRoomUseCase {
  /// Constructor
  DeleteChatRoomUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultVoid call(String roomId) => repository.deleteChatRoom(roomId);
}
