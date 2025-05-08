import '../../../core/utils/typedefs.dart';
import '../../entities/chat_room.dart';
import '../../repositories/chat_repository.dart';

class GetChatRoomByParticipantsUseCase {
  GetChatRoomByParticipantsUseCase(this.repository);
  final ChatRepository repository;

  ResultFuture<ChatRoom?> call(List<String> participants) =>
      repository.getChatRoomByParticipants(participants);
}
