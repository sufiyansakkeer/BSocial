// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPass;
  // final IconButton iconButton;
  final Widget? suffixButton;
  final TextInputType textInputType;
  const TextFieldInput({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isPass = false,
    required this.textInputType,
    this.suffixButton,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(10),
        suffixIcon: suffixButton,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
