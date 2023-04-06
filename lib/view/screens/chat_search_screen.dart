import 'dart:developer';

import 'package:bsocial/provider/chat_search_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
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
        child: Consumer<ChatSearchProvider>(builder: (context, value, child) {
          return Column(
            children: [
              TextFormField(
                controller: value.chatSearchController,
                onFieldSubmitted: (text) {
                  log(text);
                },
              ),
              kHeight20,
              FilledButton(
                onPressed: () {
                  value.showUser;
                },
                child: const Text(
                  "Search",
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      // .doc(FirebaseAuth.instance.currentUser!.uid)
                      .where("username",
                          isGreaterThanOrEqualTo:
                              value.chatSearchController.text)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    log((snapshot.data! as dynamic).docs.length.toString());
                    if (!snapshot.hasData) {
                      return Center(child: Text("no users found"));
                    } else {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return value.showUser
                            ? ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                    ),
                                    title: Text("username"),
                                  );
                                },
                                itemCount: snapshot.data.docs.length,
                              )
                            : Center(
                                child: Text("No user found"),
                              );
                      }
                    }
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
