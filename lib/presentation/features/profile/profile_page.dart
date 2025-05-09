import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/post/post_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.userId,
    super.key,
    this.isCurrentUser = false,
  });
  final String userId;
  final bool isCurrentUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _profileUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user posts when the page is first loaded
    context.read<PostBloc>().add(LoadUserPostsEvent(userId: widget.userId));

    // If not current user, fetch the user data
    if (!widget.isCurrentUser) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the user repository from context
      final userRepository = context.read<UserRepository>();

      // Fetch user data
      final result = await userRepository.getUserById(widget.userId);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (user) {
          setState(() {
            _profileUser = user;
            _isLoading = false;

            // Check if current user is following this user
            if (context.read<AuthBloc>().state is Authenticated) {
              final currentUser =
                  (context.read<AuthBloc>().state as Authenticated).user;
              _isFollowing = user.followers.contains(currentUser.uid);
            }
          });
        },
      );
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (context.read<AuthBloc>().state is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to follow users')),
      );
      return;
    }

    final currentUser = (context.read<AuthBloc>().state as Authenticated).user;

    setState(() {
      _isLoading = true;
    });

    try {
      final userRepository = context.read<UserRepository>();

      if (_isFollowing) {
        // Unfollow user
        final result = await userRepository.unfollowUser(widget.userId);

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          },
          (_) {
            setState(() {
              _isFollowing = false;
              if (_profileUser != null) {
                final updatedFollowers =
                    List<String>.from(_profileUser!.followers)
                      ..remove(currentUser.uid);
                _profileUser = User(
                  email: _profileUser!.email,
                  uid: _profileUser!.uid,
                  photoUrl: _profileUser!.photoUrl,
                  userName: _profileUser!.userName,
                  followers: updatedFollowers,
                  following: _profileUser!.following,
                  status: _profileUser!.status,
                );
              }
            });
          },
        );
      } else {
        // Follow user
        final result = await userRepository.followUser(widget.userId);

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          },
          (_) {
            setState(() {
              _isFollowing = true;
              if (_profileUser != null) {
                final updatedFollowers =
                    List<String>.from(_profileUser!.followers)
                      ..add(currentUser.uid);
                _profileUser = User(
                  email: _profileUser!.email,
                  uid: _profileUser!.uid,
                  photoUrl: _profileUser!.photoUrl,
                  userName: _profileUser!.userName,
                  followers: updatedFollowers,
                  following: _profileUser!.following,
                  status: _profileUser!.status,
                );
              }
            });
          },
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.isCurrentUser ? 'My Profile' : 'User Profile'),
          actions: [
            if (widget.isCurrentUser)
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon')),
                  );
                },
              ),
            if (widget.isCurrentUser)
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
              ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // For current user, use the authenticated user
            // For other users, use the fetched profile user
            final user = widget.isCurrentUser && authState is Authenticated
                ? authState.user
                : _profileUser;

            if (widget.isCurrentUser && authState is! Authenticated) {
              return const Center(
                child: Text('You need to be logged in to view your profile'),
              );
            }

            if (!widget.isCurrentUser && _isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!widget.isCurrentUser && _errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUserData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (user == null) {
              return const Center(
                child: Text('User not found'),
              );
            }

            return Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Banner Image
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Placeholder color
                      ),
                      child: Image.network(
                        'https://via.placeholder.com/600x200', // Placeholder image
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.error_outline)),
                      ),
                    ),
                    // Profile Picture
                    GestureDetector(
                      onTap: () {
                        // Add animation here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Profile picture tapped')),
                        );
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                    ),
                  ],
                ),
                // User Information
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.status ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Follower/Following Counts
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                          'Posts',
                          context.read<PostBloc>().state is UserPostsLoaded
                              ? (context.read<PostBloc>().state
                                      as UserPostsLoaded)
                                  .posts
                                  .length
                                  .toString()
                              : '0'),
                      _buildStatColumn(
                          'Followers', user.followers.length.toString()),
                      _buildStatColumn(
                          'Following', user.following.length.toString()),
                    ],
                  ),
                ),
                // Edit Profile/Follow Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: widget.isCurrentUser
                        ? OutlinedButton(
                            onPressed: () {
                              // Navigate to edit profile
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Edit profile coming soon')),
                              );
                            },
                            child: const Text('Edit Profile'),
                          )
                        : ElevatedButton(
                            onPressed: _isLoading ? null : _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFollowing ? Colors.grey[300] : null,
                              foregroundColor:
                                  _isFollowing ? Colors.black : null,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(_isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tabs
                Material(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Posts grid
                      _buildPostsGrid(),
                      // Saved posts
                      const Center(
                        child: Text('Saved posts will appear here'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildStatColumn(String title, String count) => Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );

  Widget _buildPostsGrid() => BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserPostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return GestureDetector(
                  onTap: () {
                    context
                        .read<PostBloc>()
                        .add(SetSelectedPostEvent(post: post));
                    context.go('/post/${post.postId}');
                  },
                  child: Image.network(
                    post.postUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  ),
                );
              },
            );
          } else if (state is PostError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PostBloc>()
                          .add(LoadUserPostsEvent(userId: widget.userId));
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Posts will appear here'),
            );
          }
        },
      );
}
