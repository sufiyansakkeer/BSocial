import 'dart:developer';
import 'dart:typed_data';
import 'package:bsocial/resources/storage_methods.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bsocial/model/user_model.dart';

import 'package:bsocial/view/screens/login_screen.dart';
import 'package:bsocial/view/widgets/custom_scackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomSnackBar customSnackBar = CustomSnackBar();

  Future<UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection("users").doc(currentUser.uid).get();
    return UserModel.fromSnapShop(snap);
  }

  ////////////////////////////////* Initializing firebase /////////////////////////////////////////////
  Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  ////////////////////////////////* signUp user /////////////////////////////////////////////
  Future<String> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List file,
  }) async {
    String res = 'some error occurred';
    try {
      log('sign up function is started');
      if (userName.isEmpty) {
        res = 'Please enter your username';
      } else if (email.isEmpty) {
        res = 'Please enter your email';
      } else if (password.isEmpty) {
        res = 'Please enter your password';
      }
      if (userName.isNotEmpty ||
          password.isNotEmpty ||
          email.isNotEmpty ||
          file != null) {
        //* registering user
        //email and password will only saved in the firebase when we use this method
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        log('if statement is working ');

        log(credential.user!.uid);

        String photoUrl =
            await StorageMethods().uploadImages('profilePics', file, false);
        //adding user to database
        UserModel userModel = UserModel(
            email: email,
            uid: credential.user!.uid,
            photoUrl: photoUrl,
            userName: userName,
            followers: [],
            following: []);

        //? if the users in collection or uid in docs is already exist it will over write the data
        await _firestore
            .collection("users")
            .doc(
              credential.user!.uid,
            )
            .set(
              userModel.toJson(),
            );
        res = "success";
        log(res);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        res = 'The email address is badly formatted.';
      } else if (error.code == 'weak-password') {
        res = "Password should be at least 6 characters";
      } else if (error.code == 'email-already-in-use') {
        res = 'This email is already exist';
      }
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

////////////////////////////////* signing without google /////////////////////////////////////////////
  Future<String> loginUser(
      {required String email, required String password}) async {
    // await _auth.signOut();

    String res = "Incorrect Email Or Password";
    try {
      if (email.isEmpty) {
        res = "enter your email";
      } else if (password.isEmpty) {
        res = "enter your password";
      }
      if (email.isNotEmpty && password.isNotEmpty) {
        //*here we don't need to store because we are signing only
        final user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        log("${user.user}");
        if (user.user?.photoURL == null) {
        } else {}

        res = "success";
      }
      // else {
      //   res = "please enter all the field";
      // }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        res = "This user doesn't exist";
      } else if (error.code == 'invalid-email') {
        res = 'Enter your email properly';
      }
    } catch (error) {
      log(error.toString());
      res = error.toString();
    }
    return res;
  }

////////////////////////////////* signOut with google /////////////////////////////////////////////
  Future<void> signOutUser(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      String status = "offline";
      // Provider.of<BottomNavigationProvider>(context).onTapIcon(0);
      await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .update({"status": status});
      await _auth.signOut();
      // log(FirebaseAuth.instance.currentUser!.uid);
      if (context.mounted) {}
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

////////////////////////////////* signing with google /////////////////////////////////////////////
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    if (context.mounted) {}
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        log(e.toString());
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          user = userCredential.user;
          UserModel userModel = UserModel(
            email: userCredential.user!.email!,
            uid: userCredential.user!.uid,
            photoUrl: user!.photoURL!,
            userName: userCredential.user!.displayName!,
            followers: [],
            following: [],
          );
          if (userCredential.additionalUserInfo!.isNewUser) {
            _firestore
                .collection("users")
                .doc(userCredential.user!.uid)
                .set(userModel.toJson());
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) {}
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar.customSnackBar(
                content:
                    'The account already exists with a different credential.',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {}
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar.customSnackBar(
              content: 'Error occurred using Google Sign-In. Try again.',
            ),
          );
        }
      } else {
        // signUpUser(userName: userName, email: email, password: password, file: file)
        log("account is doesn't exist");
      }
    }

    return user;
  }
}
