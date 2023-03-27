import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.snap});
  final snap;
  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = Provider.of<UsersProvider>(context).getUser;
    return userModel == null
        ? const CircularProgressIndicator()
        : Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    snap["profilePic"],
                  ),
                  radius: 18,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
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
                                text: snap["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " ${snap["text"]}",
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd().format(
                              snap["datePublished"].toDate(),
                            ),
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
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    Icons.favorite_border,
                  ),
                )
              ],
            ),
          );
  }
}
