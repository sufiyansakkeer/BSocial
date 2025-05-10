import '../../../../core/utils/typedefs.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

/// Use case to get a chat room by participants
class GetChatRoomByParticipantsUseCase {
  /// Constructor
  GetChatRoomByParticipantsUseCase(this.repository);
  
  /// Chat repository
  final ChatRepository repository;

  /// Execute the use case
  ResultFuture<ChatRoom?> call(List<String> participants) => 
      repository.getChatRoomByParticipants(participants);
}
