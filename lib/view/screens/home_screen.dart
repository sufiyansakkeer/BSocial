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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("online");
  }

  void setStatus(String status) async {
    _firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("online");
    } else {
      //offline
      setStatus("offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(builder: (context, usersProvider, child) {
      return RefreshIndicator(
        onRefresh: () {
          return FirebaseFirestore.instance
              .collection("posts")
              .orderBy("datePublished", descending: true)
              .get();
        },
        child: StreamBuilder(
          // here we use snapshot instead of get , because get will return a future function
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy("datePublished", descending: true)
              .snapshots(),
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
                          : PostCard(
                              postModel: postModelList[index],
                              // photoUrl: userSnapshot.data["photoUrl"],
                              // username: userSnapshot.data["username"],
                            );
                      ;
                    },
                  ),
                );
              }
            }
          },
        ),
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
