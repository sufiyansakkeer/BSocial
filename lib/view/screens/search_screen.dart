import 'dart:developer';

import 'package:bsocial/provider/search_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data!.docs[index]["photoUrl"]),
                              ),
                              title:
                                  Text(snapshot.data!.docs[index]["username"]),
                            );
                          },
                          itemCount: (snapshot.data! as dynamic).docs.length,
                        );
                      },
                    )
                  : Text("posts");
            }),
          )),
    );
  }
}
