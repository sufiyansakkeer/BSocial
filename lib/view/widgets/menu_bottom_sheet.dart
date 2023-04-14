import 'dart:developer';

import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/view/screens/account_page.dart';
import 'package:bsocial/view/screens/edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuBottomSheet extends StatelessWidget {
  const MenuBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            title: const Text("About"),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AccountPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => EditScreen(),
              ));
            },
          ),
          ListTile(
            onTap: () async {
              const url =
                  'mailto:sufiyansakkeer616@gmail.com?subject=Help me&body=need help';
              Uri uri = Uri.parse(url);

              await launchUrl(uri);
            },
            title: const Text(
              'Feedback',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            leading: const Icon(
              Icons.chat_outlined,
              color: Colors.white,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: ((context) {
                  return AlertDialog(
                    title: const Text(
                      'alert! ',
                      style: TextStyle(color: Colors.red),
                    ),
                    content: const Text('Do you want to Sign out.'),
                    actions: [
                      TextButton(
                          onPressed: (() {
                            log(FirebaseAuth.instance.currentUser!.uid);
                            AuthMethods().signOutUser(context);
                            Navigator.of(context).pop();
                          }),
                          child: const Text(
                            'yes',
                          )),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).pop();
                        }),
                        child: const Text(
                          'no',
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
            title: const Text("Sign out"),
            leading: const Icon(
              Icons.exit_to_app_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
