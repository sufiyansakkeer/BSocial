import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/size.dart';
import 'package:bsocial/provider/login_screen_provider.dart';
import 'package:bsocial/resources/auth_methods.dart';
import 'package:bsocial/view/widgets/google_sign_in_button.dart';
import 'package:bsocial/view/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              kHeight20,
              //logo
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Image.asset(
                  "assets/BSocial-1.png",
                  fit: BoxFit.contain,
                ),
              ),
              kHeight50,
              kHeight50,
              //email form field
              Consumer<LoginScreenProvider>(
                  builder: (context, provider, child) {
                return TextFieldInput(
                  controller: provider.emailTextController,
                  hintText: "Enter your email",
                  textInputType: TextInputType.emailAddress,
                );
              }),
              kHeight20,
              //password field
              Consumer<LoginScreenProvider>(
                  builder: (context, provider, child) {
                return TextFieldInput(
                  controller: provider.passwordTextController,
                  hintText: "Password",
                  textInputType: TextInputType.text,
                  isPass: true,
                );
              }),
              kHeight20,
              //sign in button
              Consumer<LoginScreenProvider>(
                  builder: (context, provider, child) {
                return InkWell(
                  onTap: () {
                    provider.loginUser(context);
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
                        : const Text("Login"),
                  ),
                );
              }),
              kHeight20,
              const Text('OR'),
              FutureBuilder(
                future: AuthMethods().initializeFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return const GoogleSignInButton(
                      text: 'Sign in with Google',
                    );
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
                height: MediaQuery.of(context).size.height * 0.17,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: const Text("Don't have an account? "),
                  ),
                  Consumer<LoginScreenProvider>(
                      builder: (ctx, provider, child) {
                    return GestureDetector(
                      onTap: () {
                        provider.navigateToSignUp(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: const Text(
                          "Sign Up",
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
        )),
      ),
    );
  }
}
