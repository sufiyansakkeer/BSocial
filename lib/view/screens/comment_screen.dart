import 'dart:developer';

import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/comment_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/resources/firestore_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/widgets/comment_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class CommentScreen extends StatelessWidget {
  const CommentScreen({super.key, required this.snap});
  final snap;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UsersProvider>(context).getUser!;
    return userModel == null
        ? const CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 0,
              title: const Text(
                "comments",
              ),
              centerTitle: true,
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .doc(snap["photoId"])
                  .collection("comments")
                  .orderBy("datePublished", descending: true)
                  .snapshots(),
              // initialData: initialData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Container();
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      log(snapshot.data!.docs.length.toString());
                      return CommentCard(
                        snap: snapshot.data!.docs[index].data(),
                      );
                    },
                    itemCount: (snapshot.data! as dynamic).docs.length,
                  );
                }
              },
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: kToolbarHeight,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        userModel.photoUrl,
                      ),
                      radius: 18,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Consumer<CommentProvider>(
                            builder: (context, value, child) {
                          return TextField(
                            controller: value.commentController,
                            decoration: InputDecoration(
                              hintText: "comment as ${userModel.userName}",
                              border: InputBorder.none,
                            ),
                          );
                        }),
                      ),
                    ),
                    Consumer<CommentProvider>(builder: (context, value, child) {
                      return InkWell(
                        onTap: () async {
                          await FireStoreMethods().postComment(
                            snap["photoId"],
                            value.commentController.text,
                            userModel.uid,
                            userModel.photoUrl,
                            userModel.userName,
                          );
                          value.disposeController();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: const Text(
                            "Post",
                            style: TextStyle(
                              color: blueColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
  }
}
