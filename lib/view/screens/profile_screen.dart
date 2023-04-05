import 'dart:developer';

import 'package:bsocial/provider/profile_screen_provider.dart';
import 'package:bsocial/provider/update_screen_provider.dart';

import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/resources/firestore_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/edit_screen.dart';
import 'package:bsocial/view/screens/followers_screen.dart';
import 'package:bsocial/view/screens/following_screen.dart';
import 'package:bsocial/view/widgets/follow_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        actions: [
          FirebaseAuth.instance.currentUser!.uid == uid
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: ((context) {
                        return AlertDialog(
                          title: const Text(
                            'alert! ',
                            style: TextStyle(color: Colors.red),
                          ),
                          content: const Text('Do you want to Sign out.'),
                          actions: [
                            TextButton(
                                onPressed: (() {
                                  AuthMethods().signOutUser(context);
                                  Navigator.of(context).pop();
                                }),
                                child: const Text(
                                  'yes',
                                )),
                            TextButton(
                              onPressed: (() {
                                Navigator.of(context).pop();
                              }),
                              child: const Text(
                                'no',
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  },
                  icon: const Icon(
                    Icons.exit_to_app_rounded,
                  ),
                )
              : const Text(""),
        ],
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
                      log("length of post is ${value.postLength}");
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
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FollowersScreen(userUid: uid),
                                      ),
                                    );
                                  },
                                  child: buildStatColumn(
                                    value.followers,
                                    'Followers',
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FollowingScreen(
                                          userUid: '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: buildStatColumn(
                                    value.following,
                                    'Following',
                                  ),
                                ),
                              ],
                            );
                          }),
                          Consumer<ProfileScreenProvider>(
                              builder: (context, value, child) {
                            // value.isChecking(uid);
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FirebaseAuth.instance.currentUser!.uid == uid
                                    ? Consumer<UpdateScreenProvider>(
                                        builder: (context, value, child) {
                                        return FollowButton(
                                          text: "Edit Profile",
                                          borderColor: Colors.white,
                                          backgroundColor:
                                              mobileBackgroundColor,
                                          textColor: Colors.white,
                                          function: () {
                                            value.getData();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditScreen(),
                                              ),
                                            );
                                            value.getData();
                                          },
                                        );
                                      })
                                    : value.isFollowing
                                        ? FollowButton(
                                            text: "Unfollow",
                                            borderColor: Colors.white,
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: Colors.white,
                                            function: () async {
                                              await FireStoreMethods()
                                                  .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      uid);
                                              value.isFollowFunctionInc();
                                              log("${value.isFollowing} value");
                                            },
                                          )
                                        : FollowButton(
                                            text: "follow",
                                            borderColor: mobileBackgroundColor,
                                            backgroundColor: Colors.white,
                                            textColor: mobileBackgroundColor,
                                            function: () async {
                                              await FireStoreMethods()
                                                  .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      uid);

                                              value.isFollowingDec();
                                            },
                                          ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                // Consumer<ProfileScreenProvider>(
                //     builder: (context, value, child) {
                //   // value.getData(uid);
                //   return Container(
                //     alignment: Alignment.centerLeft,
                //     padding: const EdgeInsets.only(
                //       top: 2,
                //     ),
                //     child: Text(
                //       value.userData["username"],
                //       style: const TextStyle(
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   );
                // }),
                // Container(
                //   alignment: Alignment.centerLeft,
                //   padding: const EdgeInsets.only(
                //     top: 2,
                //   ),
                //   child: const Text(
                //     "some description",
                //     style: TextStyle(
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasData) {
                log("snapshot has data");
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    return Container(
                      child: Image.network(
                        snap["postUrl"],
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("Add Post to See here"),
                );
              }
            },
            future: FirebaseFirestore.instance
                .collection("posts")
                .where("uid", isEqualTo: uid)
                .get(),
          )
        ],
      ),
    );
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
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
