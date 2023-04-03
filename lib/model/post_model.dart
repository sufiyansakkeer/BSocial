// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String description;
  final String uid;
  final String userName;
  final String photoId;
  final datePublished;
  final String postUrl;
  final String profileImg;
  final likes;

  PostModel({
    required this.userName,
    required this.likes,
    required this.description,
    required this.uid,
    required this.photoId,
    required this.datePublished,
    required this.postUrl,
    required this.profileImg,
  });
//here we used string as the first dataType because the key is string type,
//* when we call this function , it will convert the arguments into the object file
  Map<String, dynamic> toJson() => {
        'description': description,
        "uid": uid,
        "username": userName,
        "photoId": photoId,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profileImg": profileImg,
        "likes": likes,
      };

  static PostModel fromSnapShop(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PostModel(
      datePublished: snap["datePublished"],
      photoId: snap["photoId"],
      description: snap["description"],
      likes: snap["likes"],
      postUrl: snap["postUrl"],
      profileImg: snap["profileImg"],
      uid: snap["uid"],
      userName: snap["username"],
    );
  }
}
