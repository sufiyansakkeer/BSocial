import 'package:bsocial/resources/auth_methods.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            AuthMethods().signOutUser(context);
          },
          child: const Text(
            'sign out',
          ),
        ),
      ),
    );
  }
}
