import 'package:bsocial/core/colors.dart';
import 'package:bsocial/core/size.dart';
import 'package:bsocial/provider/login_screen_provider.dart';
import 'package:bsocial/view/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final TextEditingController emailTextController = TextEditingController();
    // final TextEditingController passwordTextController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
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
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      color: blueColor),
                  child: const Text("Login"),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              kHeight20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: const Text("Don't have an account? "),
                  ),
                  GestureDetector(
                    onTap: () {},
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
                  ),
                ],
              ),
              //navigate to sign up page
            ],
          ),
        ),
      ),
    );
  }
}
