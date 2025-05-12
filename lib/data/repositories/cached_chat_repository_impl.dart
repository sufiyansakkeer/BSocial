import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/chat_room.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/hive_local_data_source.dart';
import '../datasources/remote/chat_remote_data_source.dart';

class CachedChatRepositoryImpl implements ChatRepository {
  CachedChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.cacheMaxAge = const Duration(hours: 24),
  });

  final ChatRemoteDataSource remoteDataSource;
  final HiveLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Duration cacheMaxAge;

  @override
  ResultFuture<ChatRoom> createChatRoom(List<String> participants) async {
    if (await networkInfo.isConnected) {
      try {
        final chatRoom = await remoteDataSource.createChatRoom(participants);
        try {
          await localDataSource.cacheChatRoom(chatRoom);
        } on Exception catch (e) {
          log('Error caching chat room: $e', name: 'createChatRoom');
        }
        return Right(chatRoom);
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
  ResultVoid deleteChatRoom(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteChatRoom(roomId);
        try {
          await localDataSource.deleteChatRoom(roomId);
        } on Exception catch (e) {
          log('Error deleting chat room from cache: $e',
              name: 'deleteChatRoom');
        }
        return const Right(null);
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
  ResultVoid deleteMessage(String messageId, String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMessage(messageId, roomId);
        try {
          await localDataSource.deleteMessage(messageId);
        } on Exception catch (e) {
          log('Error deleting message from cache: $e', name: 'deleteMessage');
        }
        return const Right(null);
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
  ResultFuture<ChatRoom> getChatRoomById(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatRoom = await remoteDataSource.getChatRoomById(roomId);
        try {
          await localDataSource.cacheChatRoom(remoteChatRoom);
        } on Exception catch (e) {
          log('Error caching chat room: $e', name: 'getChatRoomById');
        }
        return Right(remoteChatRoom);
      } on ServerException catch (e) {
        try {
          final localChatRoom = await localDataSource.getChatRoom(roomId);
          if (localChatRoom != null) {
            log('Returning chat room from cache after remote failure',
                name: 'getChatRoomById');
            return Right(localChatRoom);
          }
        } on Exception catch (cacheE) {
          log('Error getting chat room from cache: $cacheE',
              name: 'getChatRoomById');
        }
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        try {
          final localChatRoom = await localDataSource.getChatRoom(roomId);
          if (localChatRoom != null) {
            log('Returning chat room from cache after remote failure',
                name: 'getChatRoomById');
            return Right(localChatRoom);
          }
        } on Exception catch (cacheE) {
          log('Error getting chat room from cache: $cacheE',
              name: 'getChatRoomById');
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localChatRoom = await localDataSource.getChatRoom(roomId);
        if (localChatRoom != null) {
          log('Returning chat room from cache due to no internet',
              name: 'getChatRoomById');
          return Right(localChatRoom);
        } else {
          return const Left(
              CacheFailure(message: 'No cached chat room available'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<ChatRoom?> getChatRoomByParticipants(
      List<String> participants) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatRoom =
            await remoteDataSource.getChatRoomByParticipants(participants);
        if (remoteChatRoom != null) {
          try {
            await localDataSource.cacheChatRoom(remoteChatRoom);
          } on Exception catch (e) {
            log('Error caching chat room: $e',
                name: 'getChatRoomByParticipants');
          }
        }
        return Right(remoteChatRoom);
      } on ServerException catch (e) {
        try {
          final userId = participants.first;
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);
          for (final room in localChatRooms) {
            if (room.participants.length == participants.length &&
                room.participants.every((p) => participants.contains(p))) {
              log('Returning chat room from cache after remote failure',
                  name: 'getChatRoomByParticipants');
              return Right(room);
            }
          }
        } on Exception catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE',
              name: 'getChatRoomByParticipants');
        }
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final userId = participants.first;
        final localChatRooms =
            await localDataSource.getChatRoomsByUserId(userId);
        for (final room in localChatRooms) {
          if (room.participants.length == participants.length &&
              room.participants.every((p) => participants.contains(p))) {
            log('Returning chat room from cache due to no internet',
                name: 'getChatRoomByParticipants');
            return Right(room);
          }
        }
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<List<ChatRoom>> getChatRooms(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatRooms = await remoteDataSource.getChatRooms(userId);
        try {
          for (final chatRoom in remoteChatRooms) {
            await localDataSource.cacheChatRoom(chatRoom);
          }
        } on Exception catch (e) {
          log('Error caching chat rooms: $e', name: 'getChatRooms');
        }
        return Right(remoteChatRooms);
      } on ServerException catch (e) {
        try {
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);
          if (localChatRooms.isNotEmpty) {
            log('Returning chat rooms from cache after remote failure',
                name: 'getChatRooms');
            return Right(localChatRooms);
          }
        } on Exception catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE',
              name: 'getChatRooms');
        }
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        try {
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);
          if (localChatRooms.isNotEmpty) {
            log('Returning chat rooms from cache after remote failure',
                name: 'getChatRooms');
            return Right(localChatRooms);
          }
        } on Exception catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE',
              name: 'getChatRooms');
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localChatRooms =
            await localDataSource.getChatRoomsByUserId(userId);
        if (localChatRooms.isNotEmpty) {
          log('Returning chat rooms from cache due to no internet',
              name: 'getChatRooms');
          return Right(localChatRooms);
        } else {
          return const Left(
              CacheFailure(message: 'No cached chat rooms available'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<List<Message>> getMessages(
    String roomId, {
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Check if we need to use pagination or not
        List<MessageModel> remoteMessageModels;

        if (startAfterDocument != null) {
          // Use pagination if startAfterDocument is provided
          remoteMessageModels = await remoteDataSource.getMessagesPaginated(
            roomId,
            limit: limit,
            startAfterDocument: startAfterDocument,
          );
        } else {
          // Use regular getMessages if no pagination is needed
          remoteMessageModels = await remoteDataSource.getMessages(roomId);
        }

        final remoteMessages =
            remoteMessageModels.map((model) => model.toEntity(roomId)).toList();

        try {
          for (final message in remoteMessages) {
            await localDataSource.cacheMessage(message);
          }
        } on Exception catch (e) {
          log('Error caching messages: $e', name: 'getMessages');
        }
        return Right(remoteMessages);
      } on ServerException catch (e) {
        try {
          final localMessages =
              await localDataSource.getMessagesByChatRoomId(roomId);
          if (localMessages.isNotEmpty) {
            log('Returning messages from cache after remote failure',
                name: 'getMessages');
            return Right(localMessages);
          }
        } on Exception catch (cacheE) {
          log('Error getting messages from cache: $cacheE',
              name: 'getMessages');
        }
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        try {
          final localMessages =
              await localDataSource.getMessagesByChatRoomId(roomId);
          if (localMessages.isNotEmpty) {
            log('Returning messages from cache after remote failure',
                name: 'getMessages');
            return Right(localMessages);
          }
        } on Exception catch (cacheE) {
          log('Error getting messages from cache: $cacheE',
              name: 'getMessages');
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localMessages =
            await localDataSource.getMessagesByChatRoomId(roomId);
        if (localMessages.isNotEmpty) {
          log('Returning messages from cache due to no internet',
              name: 'getMessages');
          return Right(localMessages);
        } else {
          return const Left(CacheFailure(
              message: 'No cached messages available for this chat room'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultVoid markMessagesAsRead(String roomId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markMessagesAsRead(roomId, userId);
        try {
          await localDataSource.markMessagesAsRead(roomId, userId);
        } on Exception catch (e) {
          log('Error marking messages as read in cache: $e',
              name: 'markMessagesAsRead');
        }
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        await localDataSource.markMessagesAsRead(roomId, userId);
        return const Right(null);
      } on Exception catch (e) {
        log('Error marking messages as read in cache: $e',
            name: 'markMessagesAsRead');
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    }
  }

  @override
  ResultFuture<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final messageModel = await remoteDataSource.sendMessage(
          roomId: roomId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
        );
        final message = messageModel.toEntity(roomId);
        try {
          await localDataSource.cacheMessage(message);
        } on Exception catch (e) {
          log('Error caching message: $e', name: 'sendMessage');
        }
        return Right(message);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
