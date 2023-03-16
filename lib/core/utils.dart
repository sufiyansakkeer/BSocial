import 'dart:developer';

import 'package:image_picker/image_picker.dart';

pickedFile(ImageSource imageSource) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: imageSource);

  if (file != null) {
    //here we used file as Uint8List because to access from the web also
    return file.readAsBytes();
  }
  log('no image is picked');
}
