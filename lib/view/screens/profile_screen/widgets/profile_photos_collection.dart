import 'dart:developer';

import 'package:bsocial/resources/firestore_methods.dart';
import 'package:bsocial/view/screens/profile_screen/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePhotos extends StatelessWidget {
  const ProfilePhotos({
    super.key,
    required this.widget,
  });

  final ProfileScreen widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
              DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];
              return InkWell(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shrinkWrap: true,
                        children: ['Delete']
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  FireStoreMethods().deletePost(snap.id);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(e),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
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
          // .orderBy("datePublished", descending: true)
          .where("uid", isEqualTo: widget.uid)
          .get(),
    );
  }
}
