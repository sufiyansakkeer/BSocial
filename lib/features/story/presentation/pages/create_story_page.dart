import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/story_bloc.dart';
import '../../../../core/widgets/buttons/bs_button.dart'; // Assuming BSButton exists
import '../../../../core/utils/snackbar_utils.dart'; // Assuming SnackbarUtils exists

class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Log e or show error to user
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Failed to pick image: $e');
      }
    }
  }

  void _postStory() {
    if (_imageFile != null) {
      context.read<StoryBloc>().add(CreateStoryEvent(imageFile: _imageFile!));
    } else {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Please select an image first.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _imageFile != null ? _postStory : null, // Enable only if image is selected
          ),
        ],
      ),
      body: BlocConsumer<StoryBloc, StoryState>(
        listener: (context, state) {
          if (state is StoryOperationSuccess) {
            SnackbarUtils.showSuccessSnackbar(context, state.message);
            // Optionally, pop navigator after a delay or if user confirms
            if (mounted) {
              Navigator.of(context).pop(); 
            }
          } else if (state is StoryError) {
            SnackbarUtils.showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_imageFile == null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library, size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text('No image selected.', style: TextStyle(fontSize: 18)),
                       const SizedBox(height: 20),
                      BSButton(
                        label: 'Pick from Gallery',
                        onPressed: () => _pickImage(ImageSource.gallery),
                        type: BSButtonType.primary,
                      ),
                      const SizedBox(height: 10),
                      BSButton(
                        label: 'Take Photo',
                        onPressed: () => _pickImage(ImageSource.camera),
                        type: BSButtonType.secondary,
                      ),
                    ],
                  ))
              else ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(_imageFile!, fit: BoxFit.contain),
                  ),
                ),
                if (state is StoryUploading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BSButton(
                      label: 'Post Story',
                      onPressed: _postStory,
                      width: double.infinity,
                      type: BSButtonType.primary,
                    ),
                  ),
                 Padding(
                    padding: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
                    child: BSButton(
                      label: 'Change Image',
                      onPressed: () => _pickImage(ImageSource.gallery), // Or show both options again
                      width: double.infinity,
                      type: BSButtonType.outlined,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
