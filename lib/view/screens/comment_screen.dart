import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/widgets/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class CommentScreen extends StatelessWidget {
  const CommentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        title: Text(
          "comments",
        ),
        centerTitle: true,
      ),
      body: CommentCard(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://plus.unsplash.com/premium_photo-1663936756535-6c29f2dc04a4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cmFuZG9tfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=1600&q=60",
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "comment as username",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Text(
                    "Post",
                    style: TextStyle(
                      color: blueColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
