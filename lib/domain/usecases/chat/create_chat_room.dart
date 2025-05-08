import '../../../core/utils/typedefs.dart';
import '../../entities/chat_room.dart';
import '../../repositories/chat_repository.dart';

class CreateChatRoomUseCase {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  ResultFuture<ChatRoom> call(List<String> participants) {
    return repository.createChatRoom(participants);
  }
}
