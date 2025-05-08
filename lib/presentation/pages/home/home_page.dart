import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../providers/post/post_provider.dart';
import '../../widgets/common/skeleton_loading.dart';
import '../../widgets/common/scroll_to_top_button.dart';
import '../../widgets/post/post_card.dart';
import '../post/add_post_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import '../chat/chat_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.status == AuthStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, authProvider),
          body: _buildBody(context, authProvider),
          bottomNavigationBar: _buildBottomNavBar(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider authProvider) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Return different screens based on the selected navigation index
    switch (navigationProvider.currentIndex) {
      case 0:
        return _buildFeedScreen();
      case 1:
        return _buildSearchScreen();
      case 2:
        return _buildAddPostScreen();
      case 3:
        return _buildNotificationsScreen();
      case 4:
        return ProfilePage(
          userId: authProvider.currentUser?.uid ?? '',
          isCurrentUser: true,
        );
      default:
        return _buildFeedScreen();
    }
  }

  Widget _buildFeedScreen() {
    // Use a stateful builder to avoid rebuilding the entire widget tree
    return StatefulBuilder(
      builder: (context, setState) {
        final postProvider = Provider.of<PostProvider>(context, listen: false);

        // Load posts if not already loaded - using a safer approach
        if (postProvider.posts.isEmpty &&
            postProvider.status != PostStatus.loading) {
          // Use Future.microtask instead of addPostFrameCallback to avoid potential issues
          Future.microtask(() {
            try {
              postProvider.getAllPosts();
            } catch (e) {
              debugPrint('Error loading posts: $e');
            }
          });
        }

        // Use Consumer only for the parts that need to react to changes
        return Consumer<PostProvider>(
          builder: (context, postProvider, _) {
            if (postProvider.status == PostStatus.loading) {
              return _buildLoadingState();
            }

            if (postProvider.status == PostStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${postProvider.errorMessage}'),
                    UiConstants.kHeight20,
                    // Use a simple ElevatedButton instead of custom animations
                    ElevatedButton(
                      onPressed: () => postProvider.getAllPosts(),
                      style: ElevatedButton.styleFrom(
                        padding: UiConstants.paddingH24V16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              UiConstants.borderRadiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (postProvider.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Use a simple icon without animations
                    const Icon(
                      Icons.post_add,
                      size: 64,
                      color: Colors.grey,
                    ),
                    UiConstants.kHeight20,
                    const Text(
                      'No posts yet. Create your first post!',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    UiConstants.kHeight20,
                    // Use a simple ElevatedButton instead of custom animations
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<NavigationProvider>(context, listen: false)
                            .setIndex(2);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: UiConstants.paddingH24V16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              UiConstants.borderRadiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Create Post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                // Post list with optimized rendering
                ListView.builder(
                  controller: _scrollController,
                  // Use caching builder for better performance
                  cacheExtent: MediaQuery.of(context).size.height * 2,
                  // Use AlwaysScrollableScrollPhysics for better performance
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Add key to help Flutter optimize rebuilds
                  key: const PageStorageKey('post_list'),
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    // Use RepaintBoundary to isolate animations and reduce flickering
                    return RepaintBoundary(
                      child: PostCard(post: postProvider.posts[index]),
                    );
                  },
                ),

                // Scroll to top button
                ScrollToTopButton(
                  scrollController: _scrollController,
                  showThreshold: 500.0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    // Optimize loading state to reduce flickering
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      // Reduce the number of skeleton items to improve performance
      itemCount: 2,
      itemBuilder: (context, index) {
        // Use RepaintBoundary to isolate animations and reduce flickering
        return RepaintBoundary(
          child: const PostCardSkeleton(),
        );
      },
    );
  }

  Widget _buildSearchScreen() {
    return const SearchPage();
  }

  Widget _buildAddPostScreen() {
    return const AddPostPage();
  }

  Widget _buildNotificationsScreen() {
    return const Center(
      child: Text('Notifications Screen - Coming Soon'),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: theme.brightness == Brightness.dark
              ? AppColors.textMuted
              : AppColors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
          ),
          currentIndex: navigationProvider.currentIndex,
          onTap: (index) {
            // Add haptic feedback
            HapticFeedback.lightImpact();
            navigationProvider.setIndex(index);
          },
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isSelected: navigationProvider.currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'Search',
              isSelected: navigationProvider.currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.add_circle_outline,
              activeIcon: Icons.add_circle,
              label: 'Post',
              isSelected: navigationProvider.currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.favorite_border_outlined,
              activeIcon: Icons.favorite,
              label: 'Activity',
              isSelected: navigationProvider.currentIndex == 3,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isSelected: navigationProvider.currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(isSelected ? activeIcon : icon),
      ),
      label: label,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final currentUser = authProvider.currentUser;
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Different app bar based on the selected tab
    switch (navigationProvider.currentIndex) {
      case 0: // Home
        return AppBar(
          title: Row(
            children: [
              const Text(
                'BSocial',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  // Navigate to chat list page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          actions: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  navigationProvider.setIndex(3); // Navigate to notifications
                },
              ),
            ),
          ],
        );

      case 1: // Search
        return AppBar(
          title: const Text(
            'Search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          centerTitle: true,
        );

      case 2: // Add Post
        return AppBar(
          title: const Text(
            'Create Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          centerTitle: true,
        );

      case 3: // Notifications
        return AppBar(
          title: const Text(
            'Activity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          centerTitle: true,
        );

      case 4: // Profile
        return AppBar(
          title: Text(
            currentUser?.userName ?? 'Profile',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Show profile menu
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to settings
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () {
                            Navigator.pop(context);
                            authProvider.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );

      default:
        return AppBar(
          title: const Text('BSocial'),
          elevation: 0,
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
        );
    }
  }
}
