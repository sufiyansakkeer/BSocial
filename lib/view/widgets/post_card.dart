import 'package:bsocial/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: mobileBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 6,
            ).copyWith(right: 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1679502459751-f51ccf9db45c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=900&q=60',
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shrinkWrap: true,
                          children: ['Delete']
                              .map(
                                (e) => InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(e),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.more_vert_outlined,
                  ),
                ),
              ],
            ),
          ),
          //image section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Image.network(
              'https://images.unsplash.com/photo-1679647144839-f17242bc61eb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=900&q=60',
              fit: BoxFit.cover,
            ),
          ),
          //like comment share

          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.comment_outlined,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.send,
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.bookmark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          //Description

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                Text(
                  '1234 likes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'username',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Hey this is the description',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    child: Text(
                      "View all 200 comments",
                      style: TextStyle(color: secondaryColor),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
                Container(
                  child: Text(
                    "22/11/2001",
                    style: TextStyle(color: secondaryColor),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4),
                ),
              ],
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          )
        ],
      ),
    );
  }
}
