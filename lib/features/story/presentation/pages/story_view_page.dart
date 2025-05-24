import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For story images
import '../blocs/story_bloc.dart';
import '../../domain/entities/story.dart';
import '../../../../core/widgets/avatars/bs_avatar.dart';
import 'dart:async'; // For Timer

class StoryViewPage extends StatefulWidget {
  final String userId; // User whose stories are being viewed

  const StoryViewPage({super.key, required this.userId});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> with SingleTickerProviderStateMixin {
  PageController? _pageController;
  AnimationController? _animationController;
  List<Story> _currentUserStories = [];
  int _currentStoryIndex = 0;
  Timer? _storyTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Animation controller for progress bar
    _animationController = AnimationController(vsync: this); 
    
    // Dispatch event to load this user's stories
    context.read<StoryBloc>().add(LoadUserStoriesEvent(userId: widget.userId));
  }

  void _setupStories(List<Story> stories) {
    _currentUserStories = stories;
    if (_currentUserStories.isNotEmpty) {
      _animationController?.duration = const Duration(seconds: 5); // Duration for each story
      _animationController?.forward();
      _startStoryTimer();
    }
    setState(() {}); // Trigger rebuild
  }
  
  void _startStoryTimer() {
    _storyTimer?.cancel(); // Cancel any existing timer
    _storyTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) { // Check if widget is still in the tree
         _nextStory();
      } else {
        timer.cancel(); // Widget is disposed, cancel timer
      }
    });
  }

  void _nextStory() {
    if (_currentStoryIndex < _currentUserStories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _pageController?.animateToPage(
        _currentStoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _animationController?.reset();
      _animationController?.forward();
    } else {
      // Last story of this user, close or go to next user's stories (if applicable)
      _storyTimer?.cancel();
      Navigator.of(context).pop(); 
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _pageController?.animateToPage(
        _currentStoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _animationController?.reset();
      _animationController?.forward();
    } else {
      // First story, do nothing or allow swipe to previous user (if applicable)
    }
  }
  
  @override
  void dispose() {
    _pageController?.dispose();
    _animationController?.dispose();
    _storyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoriesLoaded && state.userSpecificStories.isNotEmpty) {
          // Filter stories for the current user if not already done by BLoC
          // Or assume userSpecificStories is already correct for widget.userId
          final storiesForThisUser = state.userSpecificStories.where((s) => s.userId == widget.userId).toList();
          if (storiesForThisUser.isNotEmpty) {
             _setupStories(storiesForThisUser);
          } else if (_currentUserStories.isEmpty) { // Only pop if no stories were ever loaded for this user
             Navigator.of(context).pop(); // No stories for this user, pop back
          }
        } else if (state is StoriesLoaded && state.userSpecificStories.isEmpty && _currentUserStories.isEmpty) {
             Navigator.of(context).pop(); // Explicitly no stories found
        }
         else if (state is StoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading stories: ${state.message}')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (_currentUserStories.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final Story currentStory = _currentUserStories[_currentStoryIndex];

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTapUp: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            onLongPressStart: (_) => _animationController?.stop(),
            onLongPressEnd: (_) => _animationController?.forward(),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _currentUserStories.length,
                  physics: const NeverScrollableScrollPhysics(), // Controlled by taps
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: _currentUserStories[index].mediaUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
                    );
                  },
                  onPageChanged: (index) {
                     setState(() {
                       _currentStoryIndex = index;
                     });
                     _animationController?.reset();
                     _animationController?.forward();
                     _startStoryTimer(); // Restart timer for new page
                  },
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      Row( // Progress bars
                        children: List.generate(_currentUserStories.length, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: LinearProgressIndicator(
                                value: index == _currentStoryIndex 
                                       ? (_animationController?.value ?? 0.0) 
                                       : (index < _currentStoryIndex ? 1.0 : 0.0),
                                backgroundColor: Colors.grey.withOpacity(0.5),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 2.0,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          BSAvatar(imageUrl: currentStory.userProfileImageUrl, radius: 18),
                          const SizedBox(width: 8),
                          Text(currentStory.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
