import '../../../core/utils/typedefs.dart';
import '../../entities/chat_room.dart';
import '../../repositories/chat_repository.dart';

class GetChatRoomByParticipantsUseCase {
  final ChatRepository repository;

  GetChatRoomByParticipantsUseCase(this.repository);

  ResultFuture<ChatRoom?> call(List<String> participants) {
    return repository.getChatRoomByParticipants(participants);
  }
}
