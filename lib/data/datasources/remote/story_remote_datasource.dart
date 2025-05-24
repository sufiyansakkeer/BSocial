import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs for stories/images
import '../../models/story_model.dart';
import '../../../core/errors/exceptions.dart'; // Assuming ServerException exists

abstract class StoryRemoteDataSource {
  Future<void> addStory({
    required File imageFile,
    required String userId,
    required String username,
    required String userProfileImageUrl,
  });

  Future<List<StoryModel>> getActiveStoriesForUser(String userId);
  Future<List<StoryModel>> getFollowedUsersActiveStories(List<String> followedUserIds);
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Uuid uuid;

  StoryRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.uuid,
  });

  @override
  Future<void> addStory({
    required File imageFile,
    required String userId,
    required String username,
    required String userProfileImageUrl,
  }) async {
    try {
      final String storyId = uuid.v4();
      final String imageFileName = '${userId}_${storyId}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef = storage.ref().child('stories_media').child(imageFileName);

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String mediaUrl = await snapshot.ref.getDownloadURL();

      final DateTime createdAt = DateTime.now();
      final DateTime expiresAt = createdAt.add(const Duration(hours: 24));

      final StoryModel story = StoryModel(
        storyId: storyId,
        userId: userId,
        username: username,
        userProfileImageUrl: userProfileImageUrl,
        mediaUrl: mediaUrl,
        mediaType: 'image',
        createdAt: createdAt,
        expiresAt: expiresAt,
      );

      await firestore.collection('stories').doc(storyId).set(story.toJson());
    } catch (e) {
      // Log e
      throw ServerException(); // Or a more specific exception
    }
  }

  @override
  Future<List<StoryModel>> getActiveStoriesForUser(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt', descending: true) // Show newest expiring soon, or use createdAt
          .get();
      return querySnapshot.docs.map((doc) => StoryModel.fromJson(doc.data())).toList();
    } catch (e) {
      // Log e
      throw ServerException();
    }
  }

  @override
  Future<List<StoryModel>> getFollowedUsersActiveStories(List<String> followedUserIds) async {
    if (followedUserIds.isEmpty) {
      return [];
    }
    try {
      // Firestore 'whereIn' query is limited to 30 comparison values in a single query.
      // If followedUserIds can be very large, this needs pagination or splitting into multiple queries.
      // For MVP, assume it's within reasonable limits or handle splitting if time allows.
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [];
      for (int i = 0; i < followedUserIds.length; i += 30) {
        final sublist = followedUserIds.sublist(i, i + 30 > followedUserIds.length ? followedUserIds.length : i + 30);
         futures.add(firestore
            .collection('stories')
            .where('userId', whereIn: sublist)
            .where('expiresAt', isGreaterThan: Timestamp.now())
            .orderBy('createdAt', descending: true) // Order by creation to see newest by user
            .get());
      }
      final List<QuerySnapshot<Map<String, dynamic>>> snapshots = await Future.wait(futures);
      final List<StoryModel> stories = [];
      for (final snapshot in snapshots) {
        stories.addAll(snapshot.docs.map((doc) => StoryModel.fromJson(doc.data())));
      }
      
      // Sort by user and then by time to group them nicely in the reel later if needed, or client can do this.
      // For now, just return the combined list. They are already ordered by createdAt from query.
      return stories;
    } catch (e) {
      // Log e
      throw ServerException();
    }
  }
}
