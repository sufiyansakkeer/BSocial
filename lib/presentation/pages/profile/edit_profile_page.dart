import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/profile/profile_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  void initState() {
    super.initState();
    // Initialize form with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).initEditForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mobileBackgroundColor,
        title: const Text('Edit Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final user = profileProvider.user;
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile image
                Stack(
                  children: [
                    profileProvider.profileImage != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage:
                                MemoryImage(profileProvider.profileImage!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(user.photoUrl),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: profileProvider.selectProfileImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                UiConstants.kHeight30,

                // Username field
                CustomTextField(
                  controller: profileProvider.usernameController,
                  hintText: 'Username',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                UiConstants.kHeight30,

                // Save button
                CustomButton(
                  text: 'Save Changes',
                  onPressed: () => _updateProfile(profileProvider),
                  isLoading: profileProvider.status == ProfileStatus.loading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateProfile(ProfileProvider profileProvider) async {
    final username = profileProvider.usernameController.text.trim();
    if (username.isEmpty) {
      SnackbarUtils.showSnackBar('Username cannot be empty', context);
      return;
    }

    final success = await profileProvider.updateProfile(
      userId: widget.userId,
      username: username,
      // In a real implementation, you would upload the image and get the URL
      // photoUrl: profileProvider.profileImage != null ? 'new_url' : null,
    );

    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSnackBar('Profile updated successfully', context);
      Navigator.of(context).pop();
    } else {
      SnackbarUtils.showSnackBar(
        profileProvider.errorMessage.isNotEmpty
            ? profileProvider.errorMessage
            : 'Failed to update profile',
        context,
      );
    }
  }
}
