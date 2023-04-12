import 'dart:developer';

import 'package:bsocial/provider/profile_screen_provider.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/colors.dart';

AppBar ProfileAppBar(BuildContext context, String uid) {
  return AppBar(
    backgroundColor: mobileBackgroundColor,
    title: Consumer<ProfileScreenProvider>(builder: (context, value, child) {
      // value.getData(uid);

      log("profile page builded");
      return Text(
        value.userData["username"],
      );
    }),
    elevation: 0,
    actions: [
      FirebaseAuth.instance.currentUser!.uid == uid
          ? IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
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
                            trailing: const Icon(
                              Icons.chat_outlined,
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
                                    content:
                                        const Text('Do you want to Sign out.'),
                                    actions: [
                                      TextButton(
                                          onPressed: (() {
                                            log(FirebaseAuth
                                                .instance.currentUser!.uid);
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
                            trailing: const Icon(Icons.exit_to_app_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.menu_rounded,
              ),
            )
          : const Text(""),
    ],
  );
}
