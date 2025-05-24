part of 'story_bloc.dart';

abstract class StoryState extends Equatable {
  const StoryState();
  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryUploading extends StoryState {} // For when a new story is being created

class StoriesLoaded extends StoryState {
  // Stores all stories fetched, typically for the main reel from followed users
  final List<Story> storiesForReel; 
  // Stores stories for a specific user, e.g., when viewing someone's profile stories
  final List<Story> userSpecificStories; 

  const StoriesLoaded({this.storiesForReel = const [], this.userSpecificStories = const []});

  @override
  List<Object?> get props => [storiesForReel, userSpecificStories];

  StoriesLoaded copyWith({
    List<Story>? storiesForReel,
    List<Story>? userSpecificStories,
  }) {
    return StoriesLoaded(
      storiesForReel: storiesForReel ?? this.storiesForReel,
      userSpecificStories: userSpecificStories ?? this.userSpecificStories,
    );
  }
}

class StoryOperationSuccess extends StoryState { // For successful uploads
  final String message;
  const StoryOperationSuccess({this.message = 'Story posted successfully!'});
   @override
  List<Object?> get props => [message];
}

class StoryError extends StoryState {
  final String message;
  const StoryError(this.message);
  @override
  List<Object?> get props => [message];
}
