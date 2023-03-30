import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          "userName",
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [],
      ),
      // body: Center(
      //   child: TextButton(
      //     onPressed: () {
      //       AuthMethods().signOutUser(context);
      //     },
      //     child: const Text(
      //       'sign out',
      //     ),
      //   ),
      // ),
    );
  }
}
