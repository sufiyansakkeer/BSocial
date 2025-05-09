import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/hive_local_data_source.dart';
import '../datasources/remote/chat_remote_data_source.dart';

/// Implementation of [ChatRepository] that uses both remote and local data
/// sources
/// with offline caching support
class CachedChatRepositoryImpl implements ChatRepository {
  CachedChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.cacheMaxAge =
        const Duration(hours: 24), // Default cache age is 24 hours
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

        // Cache the chat room locally
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
  ResultVoid deleteChatRoom(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteChatRoom(roomId);

        // Delete from local cache
        try {
          await localDataSource.deleteChatRoom(roomId);
        } catch (e) {
          log('Error deleting chat room from cache: $e');
          // Continue even if cache deletion fails
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

        // Delete from local cache
        try {
          await localDataSource.deleteMessage(messageId);
        } catch (e) {
          log('Error deleting message from cache: $e');
          // Continue even if cache deletion fails
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
  ResultFuture<ChatRoom> getChatRoomById(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get chat room from remote
        final remoteChatRoom = await remoteDataSource.getChatRoomById(roomId);

        // Cache chat room locally
        try {
          await localDataSource.cacheChatRoom(remoteChatRoom);
        } catch (e) {
          log('Error caching chat room: $e');
          // Continue even if caching fails
        }

        return Right(remoteChatRoom);
      } on ServerException catch (e) {
        // Try to get chat room from local cache if remote fails
        try {
          final localChatRoom = await localDataSource.getChatRoom(roomId);
          if (localChatRoom != null) {
            log('Returning chat room from cache after remote failure');
            return Right(localChatRoom);
          }
        } catch (cacheE) {
          log('Error getting chat room from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get chat room from local cache if remote fails
        try {
          final localChatRoom = await localDataSource.getChatRoom(roomId);
          if (localChatRoom != null) {
            log('Returning chat room from cache after remote failure');
            return Right(localChatRoom);
          }
        } catch (cacheE) {
          log('Error getting chat room from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get chat room from local cache
      try {
        final localChatRoom = await localDataSource.getChatRoom(roomId);
        if (localChatRoom != null) {
          log('Returning chat room from cache due to no internet');
          return Right(localChatRoom);
        } else {
          return const Left(
              CacheFailure(message: 'No cached chat room available'));
        }
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
        // Get chat room from remote
        final remoteChatRoom =
            await remoteDataSource.getChatRoomByParticipants(participants);

        if (remoteChatRoom != null) {
          // Cache chat room locally
          try {
            await localDataSource.cacheChatRoom(remoteChatRoom);
          } catch (e) {
            log('Error caching chat room: $e');
            // Continue even if caching fails
          }
        }

        return Right(remoteChatRoom);
      } on ServerException catch (e) {
        // Try to get chat rooms from local cache and filter by participants
        try {
          final userId =
              participants.first; // Use first participant as reference
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);

          // Find a chat room with exactly these participants
          for (final room in localChatRooms) {
            if (room.participants.length == participants.length &&
                room.participants.every((p) => participants.contains(p))) {
              log('Returning chat room from cache after remote failure');
              return Right(room);
            }
          }
        } catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get chat rooms from local cache
      try {
        final userId = participants.first; // Use first participant as reference
        final localChatRooms =
            await localDataSource.getChatRoomsByUserId(userId);

        // Find a chat room with exactly these participants
        for (final room in localChatRooms) {
          if (room.participants.length == participants.length &&
              room.participants.every((p) => participants.contains(p))) {
            log('Returning chat room from cache due to no internet');
            return Right(room);
          }
        }

        return const Right(null); // No matching chat room found
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<List<ChatRoom>> getChatRooms(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get chat rooms from remote
        final remoteChatRooms = await remoteDataSource.getChatRooms(userId);

        // Cache chat rooms locally
        try {
          for (final chatRoom in remoteChatRooms) {
            await localDataSource.cacheChatRoom(chatRoom);
          }
        } catch (e) {
          log('Error caching chat rooms: $e');
          // Continue even if caching fails
        }

        return Right(remoteChatRooms);
      } on ServerException catch (e) {
        // Try to get chat rooms from local cache if remote fails
        try {
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);
          if (localChatRooms.isNotEmpty) {
            log('Returning chat rooms from cache after remote failure');
            return Right(localChatRooms);
          }
        } catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get chat rooms from local cache if remote fails
        try {
          final localChatRooms =
              await localDataSource.getChatRoomsByUserId(userId);
          if (localChatRooms.isNotEmpty) {
            log('Returning chat rooms from cache after remote failure');
            return Right(localChatRooms);
          }
        } catch (cacheE) {
          log('Error getting chat rooms from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get chat rooms from local cache
      try {
        final localChatRooms =
            await localDataSource.getChatRoomsByUserId(userId);
        if (localChatRooms.isNotEmpty) {
          log('Returning chat rooms from cache due to no internet');
          return Right(localChatRooms);
        } else {
          return const Left(
              CacheFailure(message: 'No cached chat rooms available'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<List<Message>> getMessages(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get messages from remote
        final remoteMessages = await remoteDataSource.getMessages(roomId);

        // Cache messages locally
        try {
          for (final message in remoteMessages) {
            // Create a message with roomId
            final messageWithRoomId = Message(
              messageId: message.messageId,
              senderId: message.senderId,
              receiverId: message.receiverId,
              content: message.content,
              timestamp: message.timestamp,
              isRead: message.isRead,
              roomId: roomId,
            );
            await localDataSource.cacheMessage(messageWithRoomId);
          }
        } catch (e) {
          log('Error caching messages: $e');
          // Continue even if caching fails
        }

        return Right(remoteMessages);
      } on ServerException catch (e) {
        // Try to get messages from local cache if remote fails
        try {
          final localMessages =
              await localDataSource.getMessagesByChatRoomId(roomId);
          if (localMessages.isNotEmpty) {
            log('Returning messages from cache after remote failure');
            return Right(localMessages);
          }
        } catch (cacheE) {
          log('Error getting messages from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get messages from local cache if remote fails
        try {
          final localMessages =
              await localDataSource.getMessagesByChatRoomId(roomId);
          if (localMessages.isNotEmpty) {
            log('Returning messages from cache after remote failure');
            return Right(localMessages);
          }
        } catch (cacheE) {
          log('Error getting messages from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get messages from local cache
      try {
        final localMessages =
            await localDataSource.getMessagesByChatRoomId(roomId);
        if (localMessages.isNotEmpty) {
          log('Returning messages from cache due to no internet');
          return Right(localMessages);
        } else {
          return const Left(CacheFailure(
              message: 'No cached messages available for this chat room'));
        }
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

        // Mark messages as read in local cache
        try {
          await localDataSource.markMessagesAsRead(roomId, userId);
        } catch (e) {
          log('Error marking messages as read in cache: $e');
          // Continue even if cache update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Mark messages as read in local cache even without internet
      try {
        await localDataSource.markMessagesAsRead(roomId, userId);
        return const Right(null);
      } catch (e) {
        log('Error marking messages as read in cache: $e');
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
        final message = await remoteDataSource.sendMessage(
          roomId: roomId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
        );

        // Cache the message locally
        try {
          // Create a message with roomId
          final messageWithRoomId = Message(
            messageId: message.messageId,
            senderId: message.senderId,
            receiverId: message.receiverId,
            content: message.content,
            timestamp: message.timestamp,
            isRead: message.isRead,
            roomId: roomId,
          );
          await localDataSource.cacheMessage(messageWithRoomId);
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
}
