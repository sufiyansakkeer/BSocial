import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/chat_room.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<Either<Failure, T>> _guardNetworkCall<T>(
      Future<T> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<ChatRoom> createChatRoom(List<String> participants) =>
      _guardNetworkCall(() => remoteDataSource.createChatRoom(participants));

  @override
  ResultVoid deleteChatRoom(String roomId) =>
      _guardNetworkCall(() => remoteDataSource.deleteChatRoom(roomId));

  @override
  ResultVoid deleteMessage(String messageId, String roomId) =>
      _guardNetworkCall(
          () => remoteDataSource.deleteMessage(messageId, roomId));

  @override
  ResultFuture<ChatRoom> getChatRoomById(String roomId) =>
      _guardNetworkCall(() => remoteDataSource.getChatRoomById(roomId));

  @override
  ResultFuture<ChatRoom?> getChatRoomByParticipants(
          List<String> participants) =>
      _guardNetworkCall(
          () => remoteDataSource.getChatRoomByParticipants(participants));

  @override
  ResultFuture<List<ChatRoom>> getChatRooms(String userId) =>
      _guardNetworkCall(() => remoteDataSource.getChatRooms(userId));

  @override
  ResultFuture<List<Message>> getMessages(String roomId) =>
      _guardNetworkCall(() => remoteDataSource.getMessages(roomId));

  @override
  ResultVoid markMessagesAsRead(String roomId, String userId) =>
      _guardNetworkCall(
          () => remoteDataSource.markMessagesAsRead(roomId, userId));

  @override
  ResultFuture<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) =>
      _guardNetworkCall(() => remoteDataSource.sendMessage(
            roomId: roomId,
            senderId: senderId,
            receiverId: receiverId,
            content: content,
          ));
}
