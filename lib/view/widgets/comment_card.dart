import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
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
              padding: EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "username",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " some description",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "23,12 ,22",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: Icon(
              Icons.favorite_border,
            ),
          )
        ],
      ),
    );
  }
}
