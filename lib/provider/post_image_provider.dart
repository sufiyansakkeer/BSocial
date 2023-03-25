import 'dart:typed_data';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bsocial/resources/firestore_methods.dart';
import 'package:bsocial/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostImageProvider extends ChangeNotifier {
  Uint8List? file;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  selectImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return BlurryContainer(
          color: Colors.transparent,
          child: SimpleDialog(
            title: const Text(
              'Create a Post',
            ),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  file = await pickedFile(
                    ImageSource.camera,
                  );
                  notifyListeners();
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Choose from Gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  file = await pickedFile(
                    ImageSource.gallery,
                  );
                  notifyListeners();
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void disposeController() {
    descriptionController.clear();
    notifyListeners();
  }

  void postImage(String uid, String userName, String profileImage,
      BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      String res = await FireStoreMethods().uploadPost(
        descriptionController.text,
        file!,
        uid,
        userName,
        profileImage,
      );
      if (context.mounted) {}
      if (res == 'success') {
        isLoading = false;
        showSnackBar('Posted', context);
        notifyListeners();
      } else {
        isLoading = false;
        showSnackBar(res, context);
        notifyListeners();
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  void clearImage() async {
    file = null;
    notifyListeners();
  }
}
