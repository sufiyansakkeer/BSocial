import '../../../core/utils/typedefs.dart';
import '../../entities/chat_room.dart';
import '../../repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  ResultFuture<List<ChatRoom>> call(String userId) {
    return repository.getChatRooms(userId);
  }
}
