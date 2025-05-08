import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../providers/post/post_provider.dart';
import '../../widgets/post/post_card.dart';
import '../post/add_post_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          appBar: AppBar(
            title: const Text('BSocial'),
            backgroundColor: AppColors.mobileBackgroundColor,
            elevation: 0,
          ),
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
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        // Load posts if not already loaded
        if (postProvider.posts.isEmpty &&
            postProvider.status != PostStatus.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            postProvider.getAllPosts();
          });
        }

        if (postProvider.status == PostStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (postProvider.status == PostStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${postProvider.errorMessage}'),
                UiConstants.kHeight20,
                ElevatedButton(
                  onPressed: () => postProvider.getAllPosts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (postProvider.posts.isEmpty) {
          return const Center(
            child: Text('No posts yet. Create your first post!'),
          );
        }

        return ListView.builder(
          itemCount: postProvider.posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: postProvider.posts[index]);
          },
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

    return BottomNavigationBar(
      backgroundColor: AppColors.mobileBackgroundColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.secondaryColor,
      currentIndex: navigationProvider.currentIndex,
      onTap: navigationProvider.setIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Add Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
