import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/chat_room_model.dart';
import '../../models/message_model.dart';
import 'chat_remote_data_source.dart';

/// Mock implementation of [ChatRemoteDataSource] for offline mode
class MockChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<ChatRoomModel> createChatRoom(List<String> participants) async {
    // Return a mock chat room or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<void> deleteMessage(String messageId, String roomId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<ChatRoomModel> getChatRoomById(String roomId) async {
    // Return a mock chat room or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<ChatRoomModel?> getChatRoomByParticipants(
      List<String> participants) async {
    // Return a mock chat room or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<List<MessageModel>> getMessages(String roomId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<List<MessageModel>> getMessagesPaginated(
    String roomId, {
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async =>
      []; // Return an empty list in offline mode

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    // Return a mock message or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }
}
