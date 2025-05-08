import '../../../core/utils/typedefs.dart';
import '../../entities/chat_room.dart';
import '../../repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  GetChatRoomsUseCase(this.repository);
  final ChatRepository repository;

  ResultFuture<List<ChatRoom>> call(String userId) =>
      repository.getChatRooms(userId);
}
