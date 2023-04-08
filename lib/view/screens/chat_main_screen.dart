import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/chat_search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // body: StreamBuilder(
      //   stream: FirebaseFirestore.instance.collection("collectionPath"),
      //   initialData: initialData,
      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     return Container(
      //       child: child,
      //     );
      //   },
      // ),,
    );
  }
}
