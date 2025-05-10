import 'dart:developer';

import 'package:dartz/dartz.dart'; // Use dartz as per pubspec.yaml

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/chat_local_data_source.dart';
import '../datasources/remote/chat_remote_data_source.dart';

/// Implementation of [ChatRepository] with caching
class ChatRepositoryImpl implements ChatRepository {
  /// Constructor
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Remote data source
  final ChatRemoteDataSource remoteDataSource;

  /// Local data source
  final ChatLocalDataSource localDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  @override
  ResultFuture<List<ChatRoom>> getChatRooms(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatRooms = await remoteDataSource.getChatRooms(userId);

        // Cache chat rooms locally
        for (final chatRoom in remoteChatRooms) {
          try {
            await localDataSource.cacheChatRoom(chatRoom);
          } catch (e) {
            log('Error caching chat room: $e');
            // Continue even if caching fails
          }
        }

        return Right(remoteChatRooms);
      } on ServerException catch (e) {
        // Try to get chat rooms from local cache if remote fails
        try {
          final localChatRooms = await localDataSource.getChatRooms(userId);
          return Right(localChatRooms);
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get chat rooms from local cache
      try {
        final localChatRooms = await localDataSource.getChatRooms(userId);
        return Right(localChatRooms);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<ChatRoom> createChatRoom(List<String> participants) async {
    if (await networkInfo.isConnected) {
      try {
        final chatRoom = await remoteDataSource.createChatRoom(participants);

        // Cache chat room locally
        try {
          await localDataSource.cacheChatRoom(chatRoom);
        } catch (e) {
          log('Error caching chat room: $e');
          // Continue even if caching fails
        }

        return Right(chatRoom);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
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

        // Cache chat room locally
        try {
          await localDataSource.cacheChatRoom(chatRoom);
        } catch (e) {
          log('Error caching chat room: $e');
          // Continue even if caching fails
        }

        return Right(chatRoom);
      } on ServerException catch (e) {
        // Try to get chat room from local cache if remote fails
        try {
          final localChatRoom = await localDataSource.getChatRoomById(roomId);
          if (localChatRoom != null) {
            return Right(localChatRoom);
          }
          return Left(ServerFailure(message: e.message));
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get chat room from local cache
      try {
        final localChatRoom = await localDataSource.getChatRoomById(roomId);
        if (localChatRoom != null) {
          return Right(localChatRoom);
        }
        return const Left(
            CacheFailure(message: 'Chat room not found in cache'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
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

        // Cache chat room locally if it exists
        if (chatRoom != null) {
          try {
            await localDataSource.cacheChatRoom(chatRoom);
          } catch (e) {
            log('Error caching chat room: $e');
            // Continue even if caching fails
          }
        }

        return Right(chatRoom);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
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

        // Cache message locally
        try {
          await localDataSource.cacheMessage(message);
        } catch (e) {
          log('Error caching message: $e');
          // Continue even if caching fails
        }

        return Right(message);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
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

        // Cache messages locally
        for (final message in messages) {
          try {
            await localDataSource.cacheMessage(message);
          } catch (e) {
            log('Error caching message: $e');
            // Continue even if caching fails
          }
        }

        return Right(messages);
      } on ServerException catch (e) {
        // Try to get messages from local cache if remote fails
        try {
          final localMessages = await localDataSource.getMessages(roomId);
          return Right(localMessages);
        } on CacheException catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get messages from local cache
      try {
        final localMessages = await localDataSource.getMessages(roomId);
        return Right(localMessages);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultVoid markMessagesAsRead(String roomId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markMessagesAsRead(roomId, userId);

        // Update local cache
        try {
          await localDataSource.markMessagesAsRead(roomId, userId);
        } catch (e) {
          log('Error updating local cache: $e');
          // Continue even if local update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
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

        // Update local cache
        try {
          await localDataSource.deleteMessage(messageId, roomId);
        } catch (e) {
          log('Error updating local cache: $e');
          // Continue even if local update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
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

        // Update local cache
        try {
          await localDataSource.deleteChatRoom(roomId);
        } catch (e) {
          log('Error updating local cache: $e');
          // Continue even if local update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
