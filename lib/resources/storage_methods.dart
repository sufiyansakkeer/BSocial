import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //adding image to the firebase
  Future<String> uploadImages(
      String childName, Uint8List file, bool isPost) async {
    //ref method is the reference to a file if that already exist or not
    //child is folder that can be either exist or not ,
    // firebase doesn't care about that ,
    //if the folder doesn't exist firebase will create a folder ,
    // And the folder name is childName
    Reference ref =
        _firebaseStorage.ref().child(childName).child(_auth.currentUser!.uid);
    // putting the data in the reference location ,
    // here we used put data instead of put file because we need to put from the web also
//? if we are posting some images the user will have multiple post ,
//? so each post should have unique id , hence we are making the child name as the id

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

//? here we used upload task because we will get the control how our file is upload to the firebase
    UploadTask uploadTask = ref.putData(file);
//?by upload task we will get a snap shot
    TaskSnapshot snapshot = await uploadTask;
//* The getDownloadURL() method in Firebase Storage allows you to get the download URL of a file
//* that you have uploaded to the Firebase Storage.
//* This URL can then be used to display the uploaded file or to share it with other users.
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
