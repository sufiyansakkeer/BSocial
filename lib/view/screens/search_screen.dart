// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:bsocial/provider/profile_screen_provider.dart';
import 'package:bsocial/provider/search_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/profile_screen/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            title: Consumer<SearchProvider>(builder: (context, value, child) {
              return TextFormField(
                controller: value.searchController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).primaryColorLight,
                  // filled: true,
                  label: Text(
                    "Search",
                  ),
                ),
                onFieldSubmitted: (String _) {
                  log(_);
                  value.showUser();
                  if (_.isEmpty) {
                    value.hideUser();
                  }
                },
              );
            }),
            actions: [
              Consumer<SearchProvider>(builder: (context, provider, child) {
                return IconButton(
                  onPressed: () {
                    provider.disposeMethod();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                  ),
                );
              }),
            ],
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return FirebaseFirestore.instance.collection("posts").get();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Consumer<SearchProvider>(builder: (context, value, child) {
                return value.isShowUser
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .where(
                              "username",
                              isGreaterThanOrEqualTo:
                                  value.searchController.text,
                            )
                            .get(),
                        // initialData: InitialData,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text("No data found"),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  "Some error occurred while fetching data"),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  log("${snapshot.data!.docs[index]["username"]}");
                                  var result = await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc((snapshot.data! as dynamic)
                                          .docs[index]["uid"])
                                      .get();
                                  var followerSnap =
                                      result.data()!["followers"];
                                  for (var uid in followerSnap) {
                                    if (uid ==
                                        FirebaseAuth
                                            .instance.currentUser!.uid) {
                                      log("loop is working");
                                      Provider.of<ProfileScreenProvider>(
                                              context,
                                              listen: false)
                                          .isFollowin = true;
                                      break;
                                    }
                                  }
                                  log("${followerSnap.toString()} is the checking function");
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        uid: (snapshot.data! as dynamic)
                                            .docs[index]["uid"],
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        (snapshot.data! as dynamic).docs[index]
                                            ["photoUrl"]),
                                  ),
                                  title: Text(
                                      snapshot.data!.docs[index]["username"]),
                                ),
                              );
                            },
                            itemCount: (snapshot.data! as dynamic).docs.length,
                          );
                        },
                      )
                    : FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("posts")
                            .get(),
                        // initialData: InitialData,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                "Error while fetching Data",
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return MasonryGridView.builder(
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            gridDelegate:
                                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemBuilder: (context, index) {
                              return Image.network(
                                  snapshot.data.docs[index]["postUrl"]);
                            },
                            itemCount: snapshot.data.docs.length,
                          );
                        },
                      );
              }),
            ),
          )),
    );
  }
}
