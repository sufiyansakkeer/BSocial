import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/interaction_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../providers/post/post_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Animated loading indicator
            AnimatedContainer(
              duration: UiConstants.animMedium,
              height: _isLoading ? 4 : 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            UiConstants.kHeight20,
            // Image selection/preview area
            Padding(
              padding: UiConstants.paddingH16,
              child: AnimatedContainer(
                duration: UiConstants.animMedium,
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusLarge),
                  child: _file != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image preview
                            Image.memory(
                              _file!,
                              fit: BoxFit.cover,
                              alignment: FractionalOffset.center,
                            ),
                            // Overlay with change image button
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: UiConstants.paddingAll12,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withAlpha(150),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _selectImage,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Change Image',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : // Image selection UI
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated upload icon
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 80,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            UiConstants.kHeight16,
                            Text(
                              'Tap to select an image',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                            UiConstants.kHeight20,
                            ElevatedButton.icon(
                              onPressed: _selectImage,
                              icon: const Icon(Icons.upload),
                              label: const Text('Upload Image'),
                              style: ElevatedButton.styleFrom(
                                padding: UiConstants.paddingH16V8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      UiConstants.borderRadiusMedium),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            UiConstants.kHeight20,
            // Caption input field
            Padding(
              padding: UiConstants.paddingH16,
              child: CustomTextField(
                controller: _descriptionController,
                hintText: 'Write a caption...',
                labelText: 'Caption',
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 5,
                filled: true,
                contentPadding: UiConstants.paddingAll16,
              ),
            ),
            UiConstants.kHeight30,
            // Post button with animation
            Padding(
              padding: UiConstants.paddingH16,
              child: CustomButton(
                text: 'Share Post',
                icon: Icons.send,
                onPressed: () {
                  // Add haptic feedback
                  HapticFeedback.mediumImpact();

                  _postImage(
                    currentUser?.uid ?? '',
                    currentUser?.userName ?? '',
                    currentUser?.photoUrl ?? '',
                  );
                },
                isLoading: _isLoading,
                animateOnTap: true,
                variant: ButtonVariant.filled,
              ),
            ),
            UiConstants.kHeight30,
          ],
        ),
      ),
    );
  }

  void _selectImage() async {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    final pickedImage = await showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusLarge),
        ),
        child: Padding(
          padding: UiConstants.paddingAll16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog title with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    UiConstants.kWidth12,
                    Text(
                      'Add Photo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              UiConstants.kHeight24,
              // Option buttons with staggered animation
              ..._buildAnimatedOptions(context),
            ],
          ),
        ),
      ),
    );

    if (pickedImage != null) {
      final file = await ImageUtils.pickImage(pickedImage);
      if (file != null) {
        setState(() {
          _file = file;
        });
      }
    }
  }

  // Build animated dialog options
  List<Widget> _buildAnimatedOptions(BuildContext context) {
    final options = [
      _buildOptionButton(
        context: context,
        icon: Icons.camera_alt,
        label: 'Take a photo',
        color: Colors.blue,
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, ImageSource.camera);
        },
        index: 0,
      ),
      _buildOptionButton(
        context: context,
        icon: Icons.photo_library,
        label: 'Choose from gallery',
        color: Colors.green,
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, ImageSource.gallery);
        },
        index: 1,
      ),
      _buildOptionButton(
        context: context,
        icon: Icons.close,
        label: 'Cancel',
        color: Colors.red,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        index: 2,
      ),
    ];

    return options;
  }

  // Build individual option button with animation
  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
            child: Container(
              padding: UiConstants.paddingAll16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
                borderRadius:
                    BorderRadius.circular(UiConstants.borderRadiusMedium),
              ),
              child: Row(
                children: [
                  Container(
                    padding: UiConstants.paddingAll8,
                    decoration: BoxDecoration(
                      color: color.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                    ),
                  ),
                  UiConstants.kWidth16,
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_file == null) {
        SnackbarUtils.showSnackBar(
          'Please select an image',
          context,
          type: SnackBarType.warning,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        SnackbarUtils.showSnackBar(
          'Please enter a caption',
          context,
          type: SnackBarType.warning,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.createPost(
        description: description,
        file: _file!,
        uid: uid,
        username: username,
        profImage: profImage,
      );

      if (success) {
        setState(() {
          _isLoading = false;
          _file = null;
          _descriptionController.clear();
        });

        if (!mounted) return;

        if (context.mounted) {
          // Navigate back to feed
          final navigationProvider =
              Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.setIndex(0);

          SnackbarUtils.showSnackBar(
            'Post created successfully',
            context,
            type: SnackBarType.success,
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        if (context.mounted) {
          final errorMessage = postProvider.errorMessage.isNotEmpty
              ? postProvider.errorMessage
              : 'Failed to create post';

          SnackbarUtils.showSnackBar(
            errorMessage,
            context,
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (context.mounted) {
        SnackbarUtils.showSnackBar(
          'An error occurred: $e',
          context,
          type: SnackBarType.error,
        );
      }
    }
  }
}
