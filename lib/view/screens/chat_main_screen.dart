import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/chat_search_screen.dart';
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
    );
  }
}
