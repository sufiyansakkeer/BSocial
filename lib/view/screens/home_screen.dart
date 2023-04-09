import 'dart:developer';

import 'package:bsocial/model/post_model.dart';
import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/chat_main_screen.dart';
import 'package:bsocial/view/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return Consumer<UsersProvider>(builder: (context, usersProvider, child) {
      return FutureBuilder(
        // here we use snapshot instead of get , because get will return a future function
        future: FirebaseFirestore.instance
            .collection('posts')
            .orderBy("datePublished", descending: true)
            .get(),
        // initialData: initialData,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error while fetching data"),
            );
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final UserModel? user = usersProvider.getUser;
              List<PostModel> postModelList = snapshot.data!.docs
                  .map((e) => PostModel.fromSnapShop(e))
                  .toList();
              if (user != null) {
                postModelList = postModelList
                    .where((element) => user.following.contains(element.uid))
                    .toList();
              } else {
                postModelList = [];
              }

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  centerTitle: false,
                  title: Image.asset(
                    "assets/BSocial-1.png",
                    height: MediaQuery.of(context).size.height * 0.035,
                  ),
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatMainScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.messenger,
                      ),
                    ),
                  ],
                ),
                body: ListView.builder(
                  itemCount: postModelList.length,
                  itemBuilder: (context, index) {
                    // if (snapshot.data!.docs[index].data()["uid"]) {}

                    return postModelList.isEmpty
                        ? Center(
                            child: Text(
                              "Please Follow some one",
                            ),
                          )
                        : StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(postModelList[index].uid)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot userSnapshot) {
                              if (userSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                      "Some error occured while fetching data"),
                                );
                              }
                              log("builder is building");
                              return PostCard(
                                postModel: postModelList[index],
                                photoUrl: userSnapshot.data["photoUrl"],
                                username: userSnapshot.data["username"],
                              );
                            },
                          );
                  },
                ),
              );
            }
          }
        },
      );
    });
  }

  Future<UserModel> usermodelFunction(PostModel postModel) async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(postModel.uid)
        .get();

    UserModel userModel = (snap.data() as dynamic);
    return userModel;
  }
}
