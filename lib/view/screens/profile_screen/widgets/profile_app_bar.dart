import 'dart:developer';

import 'package:bsocial/provider/profile_screen_provider.dart';

import 'package:bsocial/view/widgets/menu_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                    return const MenuBottomSheet();
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
