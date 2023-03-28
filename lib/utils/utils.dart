import 'dart:developer';

import 'package:bsocial/utils/utils.dart';
import 'package:bsocial/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'utils.dart';
import 'package:flutter/scheduler.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
pickedFile(ImageSource imageSource) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: imageSource);

  if (file != null) {
    //here we used file as Uint8List because to access from the web also
    return file.readAsBytes();
  }
  log('no image is picked');
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
      ),
    ),
  );
}
