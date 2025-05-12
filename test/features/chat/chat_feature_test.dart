import 'package:bsocial/features/chat/data/datasources/remote/message_stream.dart';
import 'package:bsocial/features/chat/data/models/message_model.dart';
import 'package:bsocial/features/chat/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseFirestore, Connectivity, DocumentReference, CollectionReference, DocumentSnapshot, QuerySnapshot, Query])
void main() {
  group('Chat Feature Tests', () {
    late MessageStream messageStream;
    late MockFirebaseFirestore mockFirestore;
    late MockConnectivity mockConnectivity;
    late MockCollectionReference mockChatsCollection;
    late MockDocumentReference mockChatRoomDoc;
    late MockCollectionReference mockMessagesCollection;
    late MockDocumentReference mockMessageDoc;
    late MockDocumentSnapshot mockDocSnapshot;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockConnectivity = MockConnectivity();
      mockChatsCollection = MockCollectionReference();
      mockChatRoomDoc = MockDocumentReference();
      mockMessagesCollection = MockCollectionReference();
      mockMessageDoc = MockDocumentReference();
      mockDocSnapshot = MockDocumentSnapshot();
      
      // Setup connectivity mock
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));
      
      // Setup Firestore mocks
      when(mockFirestore.collection(any)).thenReturn(mockChatsCollection);
      when(mockChatsCollection.doc(any)).thenReturn(mockChatRoomDoc);
      when(mockChatRoomDoc.collection(any)).thenReturn(mockMessagesCollection);
      when(mockMessagesCollection.doc(any)).thenReturn(mockMessageDoc);
      when(mockMessageDoc.set(any)).thenAnswer((_) async => {});
      when(mockChatRoomDoc.update(any)).thenAnswer((_) async => {});
      
      // Initialize message stream
      messageStream = MessageStream(
        firestore: mockFirestore,
        connectivity: mockConnectivity,
      );
    });
    
    test('sendMessage should send a message successfully when online', () async {
      // Arrange
      const roomId = 'test_room_id';
      const senderId = 'sender_id';
      const receiverId = 'receiver_id';
      const content = 'Test message';
      
      // Act
      final result = await messageStream.sendMessage(
        roomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
      
      // Assert
      expect(result, isA<MessageModel>());
      expect(result.content, equals(content));
      expect(result.senderId, equals(senderId));
      expect(result.receiverId, equals(receiverId));
      expect(result.roomId, equals(roomId));
      expect(result.status, equals(MessageStatus.sent));
      
      // Verify Firestore interactions
      verify(mockFirestore.collection(any)).called(2); // chats collection called twice
      verify(mockChatsCollection.doc(roomId)).called(2); // room doc called twice
      verify(mockChatRoomDoc.collection(any)).called(1); // messages collection called once
      verify(mockMessagesCollection.doc(any)).called(1); // message doc called once
      verify(mockMessageDoc.set(any)).called(1); // set called once
      verify(mockChatRoomDoc.update(any)).called(1); // update called once
    });
    
    test('sendMessage should queue message when offline', () async {
      // Arrange
      const roomId = 'test_room_id';
      const senderId = 'sender_id';
      const receiverId = 'receiver_id';
      const content = 'Test offline message';
      
      // Mock offline connectivity
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.none));
      
      // Reinitialize with offline connectivity
      messageStream = MessageStream(
        firestore: mockFirestore,
        connectivity: mockConnectivity,
      );
      
      // Act
      final result = await messageStream.sendMessage(
        roomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
      
      // Assert
      expect(result, isA<MessageModel>());
      expect(result.content, equals(content));
      expect(result.status, equals(MessageStatus.failed));
      
      // Verify no Firestore interactions occurred
      verifyNever(mockMessageDoc.set(any));
      verifyNever(mockChatRoomDoc.update(any));
    });
    
    // Add more tests for other chat functionality
  });
}
