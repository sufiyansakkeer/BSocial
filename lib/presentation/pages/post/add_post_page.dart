import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../providers/post/post_provider.dart';
import '../../widgets/common/custom_button.dart';

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
        backgroundColor: AppColors.mobileBackgroundColor,
        title: const Text('Create Post'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading ? const LinearProgressIndicator() : const SizedBox(),
            UiConstants.kHeight20,
            _file != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.cover,
                              alignment: FractionalOffset.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.upload),
                          onPressed: _selectImage,
                        ),
                      ),
                    ),
                  ),
            UiConstants.kHeight20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
                maxLines: 8,
              ),
            ),
            UiConstants.kHeight20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: 'Post',
                onPressed: () => _postImage(
                  currentUser?.uid ?? '',
                  currentUser?.userName ?? '',
                  currentUser?.photoUrl ?? '',
                ),
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage() async {
    final pickedImage = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Create a Post'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Take a photo'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Choose from gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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

  void _postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_file == null) {
        SnackbarUtils.showSnackBar('Please select an image', context);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        SnackbarUtils.showSnackBar('Please enter a caption', context);
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

          SnackbarUtils.showSnackBar('Post created successfully', context);
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

          SnackbarUtils.showSnackBar(errorMessage, context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (context.mounted) {
        SnackbarUtils.showSnackBar('An error occurred: $e', context);
      }
    }
  }
}
