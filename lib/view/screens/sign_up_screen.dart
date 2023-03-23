import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
import 'package:bsocial/provider/sign_up_provider.dart';
import 'package:bsocial/utils/utils.dart';
import 'package:bsocial/view/widgets/google_sign_in_button.dart';
import 'package:bsocial/view/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flexible(
                //   flex: 2,
                //   child: Container(),
                // ),
                kHeight20,
                //logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Image.asset(
                    "assets/BSocial-1.png",
                    fit: BoxFit.contain,
                  ),
                ),
                kHeight50,
                // kHeight50,
                //avatar
                // Stack(
                //   children: [
                //     Consumer<SignUpScreenProvider>(
                //         builder: (context, provider, child) {
                //       return provider.image != null
                //           ? CircleAvatar(
                //               backgroundImage: MemoryImage(provider.image!),
                //               radius: 64,
                //             )
                //           : const CircleAvatar(
                //               backgroundImage: NetworkImage(
                //                 "https://img.freepik.com/free-icon/user_318-159711.jpg",
                //               ),
                //               radius: 64,
                //             );
                //     }),
                //     Positioned(
                //       bottom: -10,
                //       left: 80,
                //       child: Consumer<SignUpScreenProvider>(
                //           builder: (context, provider, child) {
                //         return IconButton(
                //           onPressed: provider.selectImage,
                //           icon: const Icon(
                //             Icons.add_a_photo_outlined,
                //           ),
                //         );
                //       }),
                //     ),
                //   ],
                // ),
                kHeight20,
                //user name form field
                Consumer<SignUpScreenProvider>(
                    builder: (context, provider, child) {
                  return TextFieldInput(
                    controller: provider.userNameController,
                    hintText: "Username",
                    textInputType: TextInputType.text,
                  );
                }),
                kHeight20,
                //
                //email form field
                Consumer<SignUpScreenProvider>(
                    builder: (context, provider, child) {
                  return TextFieldInput(
                    controller: provider.emailTextController,
                    hintText: "Email",
                    textInputType: TextInputType.emailAddress,
                  );
                }),
                kHeight20,
                //password field
                Consumer<SignUpScreenProvider>(
                    builder: (context, provider, child) {
                  return TextFieldInput(
                    controller: provider.passwordTextController,
                    hintText: "Password",
                    textInputType: TextInputType.text,
                    isPass: provider.isPass1,
                    suffixButton: GestureDetector(
                      onTap: () => provider.showPassword1(),
                      child: Icon(
                        provider.isPass1
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  );
                }),
                kHeight20,
                Consumer<SignUpScreenProvider>(
                    builder: (context, provider, child) {
                  return TextFieldInput(
                    controller: provider.passwordTextController2,
                    hintText: "Password",
                    textInputType: TextInputType.text,
                    isPass: provider.isPass2,
                    suffixButton: GestureDetector(
                      onTap: () => provider.showPassword2(),
                      child: Icon(
                        provider.isPass2
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  );
                }),
                kHeight20,
                //sign in button
                Consumer<SignUpScreenProvider>(builder: (ctx, provider, child) {
                  return InkWell(
                    onTap: () async {
                      bool result =
                          await InternetConnectionChecker().hasConnection;
                      if (context.mounted) {
                        if (result) {
                          provider.passWordChecking()
                              ? provider.signUpUser(context)
                              : showSnackBar(
                                  "'Password doesn't matching", context);
                        } else {
                          showSnackBar(
                              'Please check your internet connection', context);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          color: blueColor),
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Sign Up"),
                    ),
                  );
                }),

                kHeight30,
                const Text('OR'),
                FutureBuilder(
                  future: AuthMethods().initializeFirebase(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error initializing Firebase');
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return const GoogleSignInButton();
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                // Expanded(
                //   child: SizedBox(
                //     width: double.infinity,
                //   ),
                // )
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: const Text("Already have an account ? "),
                    ),
                    Consumer<SignUpScreenProvider>(
                        builder: (ctx, provider, child) {
                      return GestureDetector(
                        onTap: () {
                          provider.navigateToLoginScreen(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                //navigate to sign up page
              ],
            ),
          ),
        ),
      ),
    );
  }
}
