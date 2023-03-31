import 'dart:developer';

import 'package:bsocial/provider/profile_screen_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/widgets/follow_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    log("building widget");
    Provider.of<ProfileScreenProvider>(context, listen: false).getData(uid);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title:
            Consumer<ProfileScreenProvider>(builder: (context, value, child) {
          // value.getData(uid);

          log("profile page builded");
          return Text(
            value.userData["username"],
          );
        }),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Consumer<ProfileScreenProvider>(
                        builder: (context, value, child) {
                      log("logggg 1 ${value.postLength}");
                      // value.getData(uid);
                      return CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          value.userData["photoUrl"],
                        ),
                        radius: 50,
                      );
                    }),
                    Expanded(
                      child: Column(
                        children: [
                          Consumer<ProfileScreenProvider>(
                              builder: (context, value, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(
                                  value.postLength,
                                  "Posts",
                                ),
                                buildStatColumn(
                                  value.followers,
                                  'Followers',
                                ),
                                buildStatColumn(
                                  value.following,
                                  'Following',
                                ),
                              ],
                            );
                          }),
                          Consumer<ProfileScreenProvider>(
                              builder: (context, value, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FirebaseAuth.instance.currentUser!.uid == uid
                                    ? FollowButton(
                                        text: "Edit Profile",
                                        borderColor: Colors.white,
                                        backgroundColor: mobileBackgroundColor,
                                        textColor: Colors.white,
                                        function: () {},
                                      )
                                    : value.isFollowing
                                        ? FollowButton(
                                            text: "Un follow",
                                            borderColor: mobileBackgroundColor,
                                            backgroundColor: Colors.white,
                                            textColor: mobileBackgroundColor,
                                            function: () {},
                                          )
                                        : FollowButton(
                                            text: "Follow",
                                            borderColor: Colors.white,
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: Colors.white,
                                            function: () {},
                                          ),
                                // FollowButton(
                                //   text: "sign Out",
                                //   borderColor: Colors.white,
                                //   backgroundColor: mobileBackgroundColor,
                                //   textColor: Colors.white,
                                //   function: () {
                                //     AuthMethods().signOutUser(context);
                                //   },
                                // ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                Consumer<ProfileScreenProvider>(
                    builder: (context, value, child) {
                  // value.getData(uid);
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      top: 2,
                    ),
                    child: Text(
                      value.userData["username"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    top: 2,
                  ),
                  child: Text(
                    "some description",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
      // body: Center(
      //   child: TextButton(
      //     onPressed: () {
      //       AuthMethods().signOutUser(context);
      //     },
      //     child: const Text(
      //       'sign out',
      //     ),
      //   ),
      // ),
    );
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          child: Text(
            label,
          ),
        ),
      ],
    );
  }
}
