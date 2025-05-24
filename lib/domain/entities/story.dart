import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String storyId;
  final String userId;
  final String username;
  final String userProfileImageUrl;
  final String mediaUrl;
  final String mediaType; // Initially "image"
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.storyId,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
        storyId,
        userId,
        username,
        userProfileImageUrl,
        mediaUrl,
        mediaType,
        createdAt,
        expiresAt,
      ];

  Story copyWith({
    String? storyId,
    String? userId,
    String? username,
    String? userProfileImageUrl,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Story(
      storyId: storyId ?? this.storyId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
