import 'dart:developer';

import 'package:bsocial/provider/search_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                decoration: const InputDecoration(
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
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<SearchProvider>(builder: (context, value, child) {
              return value.isShowUser
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .where(
                            "username",
                            isGreaterThanOrEqualTo: value.searchController.text,
                          )
                          .get(),
                      // initialData: InitialData,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("No data found"),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child:
                                Text("Some error occurred while fetching data"),
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
                            log("${(snapshot.data)}");
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    (snapshot.data! as dynamic).docs[index]
                                        ["photoUrl"]),
                              ),
                              title:
                                  Text(snapshot.data!.docs[index]["username"]),
                            );
                          },
                          itemCount: (snapshot.data! as dynamic).docs.length,
                        );
                      },
                    )
                  : FutureBuilder(
                      future:
                          FirebaseFirestore.instance.collection("posts").get(),
                      // initialData: InitialData,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text(
                              "Error while fetching Data",
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return MasonryGridView.builder(
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (context, index) {
                            return Image.network(
                                snapshot.data.docs[index]["postUrl"]);
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      },
                    );
            }),
          )),
    );
  }
}
