import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/post_bloc.dart';

/// Page for creating a new post
class AddPostPage extends StatefulWidget {
  /// Constructor
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Select an image from the gallery
  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _image = imageBytes;
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Create a new post
  void _createPost() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PostBloc>().add(
            CreatePostEvent(
              description: _descriptionController.text,
              image: _image!,
              userId: authState.user.uid,
              username: authState.user.userName,
              profileImage: authState.user.photoUrl,
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _createPost,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Post'),
            ),
          ],
        ),
        body: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.loading) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state.status == PostStatus.postCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/');
            } else if (state.status == PostStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) => SingleChildScrollView(
            child: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
                const SizedBox(height: 16),
                // Image preview
                GestureDetector(
                  onTap: _selectImage,
                  child: _image != null
                      ? Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 64),
                              SizedBox(height: 16),
                              Text('Tap to select an image'),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                // Description input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
