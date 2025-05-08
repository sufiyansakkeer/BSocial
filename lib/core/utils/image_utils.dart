import 'dart:developer';
import 'package:image_picker/image_picker.dart';

// Image utility functions moved from utils/utils.dart
class ImageUtils {
  // Pick an image from the specified source
  static Future<dynamic> pickImage(ImageSource imageSource) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file = await imagePicker.pickImage(source: imageSource);

    if (file != null) {
      // Return file as Uint8List to be compatible with web
      return file.readAsBytes();
    }

    log('No image was picked');
    return null;
  }
}
