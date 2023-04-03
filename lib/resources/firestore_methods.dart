import 'dart:developer';
import 'dart:typed_data';

import 'package:bsocial/model/post_model.dart';
import 'package:bsocial/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
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

  Future<void> postComment(String postId, String text, String uid,
      String profilePic, String name) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set(
          {
            "profilePic": profilePic,
            "name": name,
            "uid": uid,
            "text": text,
            "commentId": commentId,
            "datePublished": DateTime.now(),
          },
        );
      } else {
        log("text is empty");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  //
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
      showSimpleNotification(
        const Text(
          "Post deleted successfully",
          textAlign: TextAlign.center,
        ),
        position: NotificationPosition.bottom,
        background: Colors.white,
      );
    } catch (e) {
      showSimpleNotification(
        const Text(
          "Some error occurred while deleting the post",
        ),
      );
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection("users").doc(uid).get();
      List following = (snap.data()! as dynamic)["following"];
      if (following.contains(followId)) {
        log("un follow function started");
        //* here we are removing the follower from the database using their uid that is followId
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayRemove(
            [uid],
          ),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        log("follow function started");
        //* here we are the followers in database
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayUnion(
            [uid],
          ),
        });
        await _firestore.collection("users").doc(uid).update({
          "following": FieldValue.arrayUnion(
            [followId],
          ),
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List> sortPost() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    List followData = (snap.data()! as dynamic)["following"];
    return followData;
  }
}
