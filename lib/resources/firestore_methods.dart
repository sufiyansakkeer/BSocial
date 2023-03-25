import 'dart:developer';
import 'dart:typed_data';

import 'package:bsocial/model/post_model.dart';
import 'package:bsocial/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //* upload post

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String userName,
    String profileImg,
  ) async {
    String res = "some error occurred";
    try {
      String photoUrl = await StorageMethods().uploadImages('post', file, true);
      //using uuid we are making unique id photo id , it provider v1 function
      String photoId = const Uuid().v1();

      PostModel postModel = PostModel(
        userName: userName,
        likes: [],
        description: description,
        uid: uid,
        photoId: photoId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImg: profileImg,
      );
      _firestore.collection("posts").doc(photoId).set(postModel.toJson());

      res = "success";
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      //here we are checking if there anything already in the like field the using the uid,
      // if the uid is exist we will delete that uid ,
      // other wise we will add that uid
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update(
          {
            "likes": FieldValue.arrayRemove(
              [uid],
            ),
          },
        );
      } else {
        await _firestore.collection("posts").doc(postId).update(
          {
            "likes": FieldValue.arrayUnion(
              [uid],
            ),
          },
        );
      }
    } catch (e) {
      log(
        e.toString(),
      );
    }
  }
}
