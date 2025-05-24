import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/story_bloc.dart';
import '../../domain/entities/story.dart';
import '../../../../core/widgets/avatars/bs_avatar.dart'; // Assuming BSAvatar exists
import '../../../../core/theme/app_colors.dart'; // For ring color
// Import StoryViewPage - will be created next, so comment out for now if it causes analyzer error for worker
// import '../pages/story_view_page.dart'; 
import 'package:go_router/go_router.dart'; // For navigation

class StoryReelWidget extends StatefulWidget {
  const StoryReelWidget({super.key});

  @override
  State<StoryReelWidget> createState() => _StoryReelWidgetState();
}

class _StoryReelWidgetState extends State<StoryReelWidget> {
  @override
  void initState() {
    super.initState();
    // Load stories when the widget is initialized
    context.read<StoryBloc>().add(LoadFollowedUsersStoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading && (state is! StoriesLoaded || (state as StoriesLoaded).storiesForReel.isEmpty)) {
          // Show shimmer or basic loading only if storiesForReel is empty in StoriesLoaded state
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        } else if (state is StoriesLoaded || (state is StoryLoading && (state as StoriesLoaded).storiesForReel.isNotEmpty)) {
          // The state can be StoryLoading but still have old storiesForReel data
          final storiesForReel = (state as StoriesLoaded).storiesForReel;

          if (storiesForReel.isEmpty) {
            return const SizedBox.shrink(); // No stories, show nothing or a placeholder
          }

          // Group stories by userId
          final Map<String, List<Story>> storiesByUser = {};
          for (var story in storiesForReel) {
            storiesByUser.putIfAbsent(story.userId, () => []).add(story);
          }
          
          // Sort users by the newest story first (optional, if stories list isn't already sorted that way)
          // For this MVP, the order from Firestore (newest overall) might be fine.

          final uniqueUserIds = storiesByUser.keys.toList();

          return SizedBox(
            height: 100, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: uniqueUserIds.length,
              itemBuilder: (context, index) {
                final userId = uniqueUserIds[index];
                final userStories = storiesByUser[userId]!;
                final firstStory = userStories.first; // To get profile info

                // TODO: Implement logic for 'viewed' status to change ring color
                final bool hasUnviewedStories = true; // Placeholder

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      // Navigate to StoryViewPage, passing the user's stories
                      // For now, let's assume StoryViewPage takes a list of stories for one user
                      // And the specific user ID to know whose stories to show first or highlight
                      context.goNamed(
                        'story-view', // Assume this route name will be created
                        pathParameters: {'userId': userId}, 
                        // extra: userStories // Pass stories if needed by StoryViewPage directly
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: hasUnviewedStories ? AppColors.primaryColor : Colors.grey,
                              width: 2.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0), // Space between border and avatar
                            child: BSAvatar(
                              imageUrl: firstStory.userProfileImageUrl,
                              radius: 30, // Adjust size
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstStory.username.length > 10 
                              ? '${firstStory.username.substring(0,8)}...' 
                              : firstStory.username,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is StoryError) {
          // Optionally show a small error indicator or allow retry
          return TextButton(
            onPressed: () => context.read<StoryBloc>().add(LoadFollowedUsersStoriesEvent()),
            child: const Text('Retry Stories')
          );
        }
        return const SizedBox(height: 100, child: Center(child: Text("Loading stories..."))); // Default loading or initial
      },
    );
  }
}
