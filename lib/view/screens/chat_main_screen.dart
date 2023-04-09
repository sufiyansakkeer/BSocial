import 'dart:developer';

import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/chat_search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMainScreen extends StatelessWidget {
  const ChatMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          "Chat screen",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatSearch(),
                ),
              );
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            // .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            log("no data in chat screen");
            return Container();
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Check your internet connection"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(snapshot.data.docs[index]["photoUrl"]),
                ),
                title: Text(snapshot.data.docs[index]["username"]),
              );
            },
            itemCount: snapshot.data.docs.length,
          );
        },
      ),
    );
  }
}
