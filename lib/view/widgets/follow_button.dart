import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.text,
    this.function,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });
  final String text;
  final Function()? function;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 2,
      ),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(
              5,
            ),
          ),
          alignment: Alignment.center,
          width: 150,
          height: 27,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
