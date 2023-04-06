import 'dart:developer';

import 'package:bsocial/provider/google_button_provider.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/responsive_layout_building.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/profile_screen_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleButtonProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: provider.isSigningIn
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () async {
                  provider.signInTrue();
                  log("google function started");
                  User? user =
                      await AuthMethods().signInWithGoogle(context: context);
                  log('user called');
                  if (context.mounted) {}
                  if (user != null) {
                    Provider.of<ProfileScreenProvider>(context, listen: false)
                        .getData(FirebaseAuth.instance.currentUser!.uid);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ResponsiveLayout(
                          webScreenLayout: WebScreenLayout(),
                          mobileScreenLayout: MobileScreenLayout(),
                        ),
                      ),
                    );
                  }
                  provider.signInFalse();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Image(
                          image: AssetImage("assets/google_logo.png"),
                          height: 24.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Google',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
