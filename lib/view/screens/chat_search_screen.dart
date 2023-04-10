import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/chat_search_provider.dart';
import 'package:bsocial/resources/chat_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
import 'package:bsocial/view/screens/messege_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatSearch extends StatelessWidget {
  ChatSearch({super.key});
  final TextEditingController chatSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("search user"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          children: [
            Consumer<ChatSearchProvider>(builder: (context, value, child) {
              return TextFormField(
                controller: value.chatSearchController,
                decoration: InputDecoration(
                  hintText: "Search User",
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onFieldSubmitted: (text) {
                  if (text.isEmpty) {
                    value.onClearUserFunction();
                    log("text is empty");
                  } else {
                    value.onSearchUserFunction();
                  }
                },
              );
            }),
            kHeight20,
            // FilledButton(
            //   onPressed: () {
            //     value.showUser;
            //   },
            //   child: const Text(
            //     "Search",
            //   ),
            // ),
            Expanded(child: Consumer<ChatSearchProvider>(
                    builder: (context, value, child) {
              return value.showUser
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          // .doc(FirebaseAuth.instance.currentUser!.uid)
                          .where("username",
                              isGreaterThanOrEqualTo:
                                  value.chatSearchController.text)
                          .get(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // log((snapshot.data! as dynamic).docs.length.toString());
                        if (!snapshot.hasData) {
                          log("snapshot has no data");
                          return const Center(
                            child: Text(
                              "no users found",
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Some error occurred while fetching data",
                            ),
                          );
                        }
                        //  else {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return
                            // value.showUser
                            //     ?
                            ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                String chatRoomId = ChatMethods().checkingId(
                                    user1: snapshot.data.docs[index]["uid"],
                                    currentUser:
                                        FirebaseAuth.instance.currentUser!.uid);

                                UserModel targetUser = UserModel(
                                    email: snapshot.data.docs[index]["email"],
                                    uid: snapshot.data.docs[index]["uid"],
                                    photoUrl: snapshot.data.docs[index]
                                        ["photoUrl"],
                                    userName: snapshot.data.docs[index]
                                        ["username"],
                                    followers: snapshot.data.docs[index]
                                        ["followers"],
                                    following: snapshot.data.docs[index]
                                        ["following"]);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    chatRoomId: chatRoomId,
                                    targetUser: targetUser,
                                  ),
                                ));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data.docs[index]["photoUrl"]),
                              ),
                              title:
                                  Text(snapshot.data.docs[index]["username"]),
                            );
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      },
                    )
                  : FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          // .doc(FirebaseAuth.instance.currentUser!.uid)

                          .get(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // log((snapshot.data! as dynamic).docs.length.toString());
                        if (!snapshot.hasData) {
                          log("snapshot has no data");
                          return const Center(
                            child: Text(
                              "no users found",
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Some error occurred while fetching data",
                            ),
                          );
                        }
                        //  else {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return
                            // value.showUser
                            //     ?
                            ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                String chatRoomId = ChatMethods().checkingId(
                                    user1: snapshot.data.docs[index]["uid"],
                                    currentUser:
                                        FirebaseAuth.instance.currentUser!.uid);

                                UserModel targetUser = UserModel(
                                    email: snapshot.data.docs[index]["email"],
                                    uid: snapshot.data.docs[index]["uid"],
                                    photoUrl: snapshot.data.docs[index]
                                        ["photoUrl"],
                                    userName: snapshot.data.docs[index]
                                        ["username"],
                                    followers: snapshot.data.docs[index]
                                        ["followers"],
                                    following: snapshot.data.docs[index]
                                        ["following"]);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    chatRoomId: chatRoomId,
                                    targetUser: targetUser,
                                  ),
                                ));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data.docs[index]["photoUrl"]),
                              ),
                              title:
                                  Text(snapshot.data.docs[index]["username"]),
                            );
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      },
                    );
            })
                // : const Center(
                //     child: Text(
                //       "No user found",
                //     ),
                //   ),
                ),
          ],
        ),
      ),
    );
  }
}
