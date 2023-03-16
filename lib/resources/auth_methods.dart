import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required Uint8List file,
  }) async {
    String res = 'some error occurred';
    try {
      if (username.isNotEmpty || password.isNotEmpty || email.isNotEmpty) {
        //* registering user
        //email and password will only saved in the firebase when we use this method
        UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        log(credential.user!.uid);
        //adding user to database
        //? if the users in collection or uid in docs is already exist it will over write the data
        await firestore.collection("users").doc(credential.user!.uid).set(
          {
            'username': username,
            "uid": credential.user!.uid,
            "email": email,
            "followers": [],
            "following": [],
          },
        );
        res = "success";
      }
    } catch (error) {
      res = error.toString();
    }
    return res;
  }
}
