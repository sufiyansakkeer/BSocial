import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const ProfilePage({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false)
          .loadUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.status == ProfileStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (profileProvider.status == ProfileStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                UiConstants.kHeight20,
                Text(
                  'Error loading profile: ${profileProvider.errorMessage}',
                  textAlign: TextAlign.center,
                ),
                UiConstants.kHeight20,
                CustomButton(
                  text: 'Retry',
                  onPressed: () =>
                      profileProvider.loadUserProfile(widget.userId),
                  width: 120,
                ),
              ],
            ),
          );
        }

        final user = profileProvider.user;
        if (user == null) {
          return const Center(
            child: Text('User not found'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.mobileBackgroundColor,
            title: Text(user.userName),
            actions: widget.isCurrentUser
                ? [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: _showProfileMenu,
                    ),
                  ]
                : null,
          ),
          body: RefreshIndicator(
            onRefresh: () => profileProvider.loadUserProfile(widget.userId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile image and stats
                        Row(
                          children: [
                            // Profile image
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.photoUrl),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(
                                    profileProvider.userPosts.length.toString(),
                                    'Posts',
                                  ),
                                  _buildStatColumn(
                                    user.followers.length.toString(),
                                    'Followers',
                                  ),
                                  _buildStatColumn(
                                    user.following.length.toString(),
                                    'Following',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        UiConstants.kHeight20,

                        // Username
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        UiConstants.kHeight,

                        // Edit profile or follow button
                        widget.isCurrentUser
                            ? CustomButton(
                                text: 'Edit Profile',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                backgroundColor:
                                    AppColors.mobileBackgroundColor,
                                textColor: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              )
                            : Consumer<UserProvider>(
                                builder: (context, userProvider, _) {
                                  final authProvider =
                                      Provider.of<AuthProvider>(context);
                                  final currentUser = authProvider.currentUser;
                                  final isFollowing = currentUser != null &&
                                      user.followers.contains(currentUser.uid);

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          text: isFollowing
                                              ? 'Unfollow'
                                              : 'Follow',
                                          onPressed: () => _handleFollowAction(
                                            context,
                                            user.uid,
                                            isFollowing,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          backgroundColor: isFollowing
                                              ? Colors.grey[800]
                                              : AppColors.blueColor,
                                        ),
                                      ),
                                      UiConstants.kWidth,
                                      Expanded(
                                        child: CustomButton(
                                          text: 'Message',
                                          onPressed: () {
                                            // Navigate to message screen
                                            SnackbarUtils.showSnackBar(
                                              'Messaging feature coming soon',
                                              context,
                                            );
                                          },
                                          backgroundColor: Colors.grey[800],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  // Divider
                  const Divider(),

                  // Posts grid
                  profileProvider.userPosts.isEmpty
                      ? SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              widget.isCurrentUser
                                  ? 'You have no posts yet'
                                  : '${user.userName} has no posts yet',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: profileProvider.userPosts.length,
                          itemBuilder: (context, index) {
                            final post = profileProvider.userPosts[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to post detail
                              },
                              child: Image.network(
                                post.postUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _handleFollowAction(
      BuildContext context, String userId, bool isFollowing) async {
    // Store the context-dependent values before the async gap
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    bool success;
    if (isFollowing) {
      success = await userProvider.unfollowUser(userId);
    } else {
      success = await userProvider.followUser(userId);
    }

    if (!mounted) return;

    if (success) {
      // Refresh the profile to update the followers count
      profileProvider.loadUserProfile(userId);
    } else {
      final errorMessage = userProvider.errorMessage.isNotEmpty
          ? userProvider.errorMessage
          : 'Failed to ${isFollowing ? 'unfollow' : 'follow'} user';

      if (context.mounted) {
        SnackbarUtils.showSnackBar(errorMessage, context);
      }
    }
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                    SnackbarUtils.showSnackBar(
                      'Settings feature coming soon',
                      context,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.signOut();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
