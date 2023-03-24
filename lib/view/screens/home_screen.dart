import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/widgets/post_card.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: Image.asset(
            "assets/BSocial-1.png",
            height: MediaQuery.of(context).size.height * 0.035,
          ),
          elevation: 0,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.messenger))],
        ),
        body: Container(
          width: double.infinity,
          // height: MediaQuery.of(context).size.height,
          // decoration: BoxDecoration(color: Colors.amber),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PostCard(),
              // const Text('Home screen '),
              // Text(FirebaseAuth.instance.currentUser!.displayName.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
