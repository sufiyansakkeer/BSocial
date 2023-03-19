import 'package:bsocial/resources/auth_methods.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Home screen '),
              TextButton(
                onPressed: () {
                  AuthMethods().signOutUser(context);
                },
                child: const Text(
                  'sign out',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
