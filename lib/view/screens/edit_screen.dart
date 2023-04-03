import 'package:bsocial/utils/colors.dart';
import 'package:flutter/material.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../../provider/sign_up_provider.dart';

import '../../utils/size.dart';
import '../../utils/utils.dart';

import '../widgets/text_field_input.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text(
            "Update",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                kHeight50,
                kHeight50,
                // avatar
                Stack(
                  children: [
                    Consumer<SignUpScreenProvider>(
                        builder: (context, provider, child) {
                      return provider.image != null
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(provider.image!),
                              radius: 64,
                            )
                          : const CircleAvatar(
                              backgroundImage: NetworkImage(
                                "https://img.freepik.com/free-icon/user_318-159711.jpg",
                              ),
                              radius: 64,
                            );
                    }),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: Consumer<SignUpScreenProvider>(
                          builder: (context, provider, child) {
                        return IconButton(
                          onPressed: provider.selectImage,
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
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
                          : const Text("Update"),
                    ),
                  );
                }),

                //navigate to sign up page
              ],
            ),
          ),
        ),
      ),
    );
  }
}
