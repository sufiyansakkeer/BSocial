part of 'story_bloc.dart'; // Assuming story_bloc.dart will be created

abstract class StoryEvent extends Equatable {
  const StoryEvent();
  @override
  List<Object?> get props => [];
}

class CreateStoryEvent extends StoryEvent {
  final File imageFile;
  // userId, username, userProfileImageUrl will be fetched from AuthBloc/UserBloc in the StoryBloc
  const CreateStoryEvent({required this.imageFile});
  @override
  List<Object?> get props => [imageFile];
}

// Event to fetch stories for the main reel (followed users)
class LoadFollowedUsersStoriesEvent extends StoryEvent {}

// Event to fetch stories for a specific user's profile view (optional for now, but good to have)
class LoadUserStoriesEvent extends StoryEvent {
  final String userId;
  const LoadUserStoriesEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// Internal event to update BLoC state when stories are fetched/updated by a subscription (if any)
// For now, we'll use it after a direct fetch.
class _StoriesUpdatedEvent extends StoryEvent {
  final List<Story> stories;
  const _StoriesUpdatedEvent(this.stories);
   @override
  List<Object?> get props => [stories];
}
