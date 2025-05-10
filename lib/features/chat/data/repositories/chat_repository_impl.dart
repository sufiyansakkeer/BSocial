import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/chat_local_data_source.dart';
import '../datasources/remote/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  ResultFuture<List<ChatRoom>> getChatRooms(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatRooms = await remoteDataSource.getChatRooms(userId);

        for (final chatRoom in remoteChatRooms) {
          try {
            await localDataSource.cacheChatRoom(chatRoom);
          } on Exception catch (e) {
            log('Error caching chat room: $e');
          }
        }

        return Right(remoteChatRooms);
      } on ServerException catch (e) {
        try {
          final localChatRooms = await localDataSource.getChatRooms(userId);
          return Right(localChatRooms);
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localChatRooms = await localDataSource.getChatRooms(userId);
        return Right(localChatRooms);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<ChatRoom> createChatRoom(List<String> participants) async {
    if (await networkInfo.isConnected) {
      try {
        final chatRoom = await remoteDataSource.createChatRoom(participants);

        try {
          await localDataSource.cacheChatRoom(chatRoom);
        } on Exception catch (e) {
          log('Error caching chat room: $e');
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
  ResultFuture<ChatRoom> getChatRoomById(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        final chatRoom = await remoteDataSource.getChatRoomById(roomId);

        try {
          await localDataSource.cacheChatRoom(chatRoom);
        } on Exception catch (e) {
          log('Error caching chat room: $e');
        }

        return Right(chatRoom);
      } on ServerException catch (e) {
        try {
          final localChatRoom = await localDataSource.getChatRoomById(roomId);
          if (localChatRoom != null) {
            return Right(localChatRoom);
          }
          return Left(ServerFailure(message: e.message));
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localChatRoom = await localDataSource.getChatRoomById(roomId);
        if (localChatRoom != null) {
          return Right(localChatRoom);
        }
        return const Left(
            CacheFailure(message: 'Chat room not found in cache'));
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
        final chatRoom =
            await remoteDataSource.getChatRoomByParticipants(participants);

        if (chatRoom != null) {
          try {
            await localDataSource.cacheChatRoom(chatRoom);
          } on Exception catch (e) {
            log('Error caching chat room: $e');
          }
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
  ResultFuture<Message> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final message = await remoteDataSource.sendMessage(
          roomId: roomId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
        );

        try {
          await localDataSource.cacheMessage(message);
        } on Exception catch (e) {
          log('Error caching message: $e');
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

  @override
  ResultFuture<List<Message>> getMessages(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await remoteDataSource.getMessages(roomId);

        for (final message in messages) {
          try {
            await localDataSource.cacheMessage(message);
          } on Exception catch (e) {
            log('Error caching message: $e');
          }
        }

        return Right(messages);
      } on ServerException catch (e) {
        try {
          final localMessages = await localDataSource.getMessages(roomId);
          return Right(localMessages);
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localMessages = await localDataSource.getMessages(roomId);
        return Right(localMessages);
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
          log('Error updating local cache: $e');
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
          await localDataSource.deleteMessage(messageId, roomId);
        } on Exception catch (e) {
          log('Error updating local cache: $e');
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
  ResultVoid deleteChatRoom(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteChatRoom(roomId);

        try {
          await localDataSource.deleteChatRoom(roomId);
        } on Exception catch (e) {
          log('Error updating local cache: $e');
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
}
