import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/story.dart';
import '../../../../domain/entities/user.dart' as DomainUser; // Alias to avoid conflict if User entity exists
import '../../../../domain/usecases/story/add_story_usecase.dart';
import '../../../../domain/usecases/story/get_followed_users_active_stories_usecase.dart';
import '../../../../domain/usecases/story/get_active_stories_for_user_usecase.dart';
import '../../../../domain/usecases/user/get_user_data_usecase.dart'; // To get current user's followed list
import '../../../auth/presentation/blocs/auth_bloc.dart'; // To get current user details

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final AddStoryUseCase addStoryUseCase;
  final GetFollowedUsersActiveStoriesUseCase getFollowedUsersActiveStoriesUseCase;
  final GetActiveStoriesForUserUseCase getActiveStoriesForUserUseCase;
  final GetUserDataUseCase getUserDataUseCase; // To fetch followed list for the reel
  final AuthBloc authBloc; // To get current user's ID, username, profile image for posting

  StoryBloc({
    required this.addStoryUseCase,
    required this.getFollowedUsersActiveStoriesUseCase,
    required this.getActiveStoriesForUserUseCase,
    required this.getUserDataUseCase,
    required this.authBloc,
  }) : super(StoryInitial()) {
    on<CreateStoryEvent>(_onCreateStory);
    on<LoadFollowedUsersStoriesEvent>(_onLoadFollowedUsersStories);
    on<LoadUserStoriesEvent>(_onLoadUserStories);
    // Corrected to handle _StoriesUpdatedEvent properly, ensuring it updates the correct part of the state.
    // This example updates storiesForReel, adjust if _StoriesUpdatedEvent is meant for userSpecificStories.
    on<_StoriesUpdatedEvent>((event, emit) {
      if (state is StoriesLoaded) {
        emit((state as StoriesLoaded).copyWith(storiesForReel: event.stories));
      } else {
        emit(StoriesLoaded(storiesForReel: event.stories));
      }
    });
  }

  Future<void> _onCreateStory(CreateStoryEvent event, Emitter<StoryState> emit) async {
    emit(StoryUploading());
    final authState = authBloc.state;
    if (authState is Authenticated) {
      // Assuming authState.user is of type UserAuth from auth feature
      // And DomainUser.User is the target for GetUserDataUseCase
      // We need to ensure AddStoryParams gets the correct user details.
      // The provided UserAuth entity has: uid, email, photoUrl, userName, followers, following etc.
      // Let's assume UserAuth's photoUrl is profilePicUrl and userName is username.
      final params = AddStoryParams(
        imageFile: event.imageFile,
        userId: authState.user.uid,
        username: authState.user.userName, // Directly from UserAuth
        userProfileImageUrl: authState.user.photoUrl, // Directly from UserAuth
      );
      final result = await addStoryUseCase(params);
      result.fold(
        (failure) => emit(StoryError(failure.message)),
        (_) {
          emit(const StoryOperationSuccess());
          // Optionally, refresh stories for the reel or user's own stories
          add(LoadFollowedUsersStoriesEvent()); // Refresh reel after posting
        }
      );
    } else {
      emit(const StoryError('User not authenticated. Cannot post story.'));
    }
  }

  Future<void> _onLoadFollowedUsersStories(LoadFollowedUsersStoriesEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    final authState = authBloc.state;
    if (authState is Authenticated) {
      // First, get the current user's data to find who they follow
      final userResult = await getUserDataUseCase(authState.user.uid);
      await userResult.fold(
        (failure) async => emit(StoryError(failure.message)),
        (DomainUser.User currentUserData) async { // Ensure this is DomainUser.User
          if (currentUserData.following.isEmpty) {
            emit(const StoriesLoaded(storiesForReel: [])); // No one followed, empty reel
            return;
          }
          final result = await getFollowedUsersActiveStoriesUseCase(currentUserData.following);
          result.fold(
            (failure) => emit(StoryError(failure.message)),
            (stories) {
              if (state is StoriesLoaded) {
                 emit((state as StoriesLoaded).copyWith(storiesForReel: stories));
              } else {
                 emit(StoriesLoaded(storiesForReel: stories));
              }
            }
          );
        },
      );
    } else {
       emit(const StoriesLoaded(storiesForReel: [])); // Not authenticated, empty reel
    }
  }
  
  Future<void> _onLoadUserStories(LoadUserStoriesEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    final result = await getActiveStoriesForUserUseCase(event.userId);
    result.fold(
      (failure) => emit(StoryError(failure.message)),
      (stories) {
        // When loading specific user stories, update the userSpecificStories part of the state
        // Ensure current state is preserved if it's StoriesLoaded, otherwise create a new one
        if (state is StoriesLoaded) {
          emit((state as StoriesLoaded).copyWith(userSpecificStories: stories));
        } else {
          emit(StoriesLoaded(userSpecificStories: stories));
        }
      }
    );
  }
}
