import 'package:bsocial/model/post_model.dart';
import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/post_card_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/resources/firestore_methods.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/comment_screen.dart';
import 'package:bsocial/view/widgets/like_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.postModel,
  });
  final PostModel postModel;
  // final String username;
  // final String photoUrl;
  @override
  Widget build(BuildContext context) {
    // WidgetsFlutterBinding.ensureInitialized();

    final UserModel? user = Provider.of<UsersProvider>(context).getUser;
    return user != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          postModel.profileImg,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postModel.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     showDialog(
                      //       context: context,
                      //       builder: (context) => Dialog(
                      //         child: ListView(
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 16,
                      //           ),
                      //           shrinkWrap: true,
                      //           children: ['Delete']
                      //               .map(
                      //                 (e) => InkWell(
                      //                   onTap: () {
                      //                     FireStoreMethods()
                      //                         .deletePost(postModel.photoId);
                      //                     Navigator.of(context).pop();
                      //                   },
                      //                   child: Container(
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 16),
                      //                     child: Text(e),
                      //                   ),
                      //                 ),
                      //               )
                      //               .toList(),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   icon: const Icon(
                      //     Icons.more_vert_outlined,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                //image section
                Consumer<PostCardProvider>(builder: (context, provider, child) {
                  return GestureDetector(
                    onDoubleTap: () async {
                      // provider.animationTrue();
                      await FireStoreMethods().likePost(
                          postModel.photoId, user.uid, postModel.likes);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            postModel.postUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: provider.isLikeAnimation ? 1 : 0,
                          child: LikeAnimation(
                            isAnimation: provider.isLikeAnimation,
                            duration: const Duration(
                              milliseconds: 350,
                            ),
                            onEnd: () {
                              provider.animationFalse();
                            },
                            child: const Icon(
                              Icons.favorite_sharp,
                              size: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                //like comment share

                Row(
                  children: [
                    Consumer<PostCardProvider>(
                        builder: (context, provider, child) {
                      return LikeAnimation(
                        isAnimation: postModel.likes.contains(
                          user.uid,
                        ),
                        smallLike: true,
                        child: IconButton(
                          onPressed: () async {
                            // provider.animationTrue();
                            await FireStoreMethods().likePost(
                                postModel.photoId, user.uid, postModel.likes);
                          },
                          icon: postModel.likes.contains(user.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                ),
                        ),
                      );
                    }),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentScreen(
                            postModel: postModel,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.comment_outlined,
                        // color: Colors.red,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: const Icon(
                    //     Icons.send,
                    //     // color: Colors.red,
                    //   ),
                    // ),
                    // Expanded(
                    //   child: Align(
                    //     alignment: Alignment.bottomRight,
                    //     child: IconButton(
                    //       onPressed: () {},
                    //       icon: const Icon(
                    //         Icons.bookmark,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                //Description

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${postModel.likes.length} likes",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: postModel.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " ${postModel.description}",
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentScreen(
                              postModel: postModel,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("posts")
                                .doc(postModel.photoId)
                                .collection('comments')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.isEmpty) {
                                  return const Text(
                                    "comments",
                                    style: TextStyle(color: secondaryColor),
                                  );
                                }
                                return Text(
                                  "View all ${snapshot.data!.docs.length} comments",
                                  style: const TextStyle(color: secondaryColor),
                                );
                              } else {
                                return const Text("View all");
                              }
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd().format(
                            postModel.datePublished.toDate(),
                          ),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              height: 100.0,
              child: Shimmer.fromColors(
                baseColor: const Color(0xFF4D4D4D),
                highlightColor: const Color(0xFF4D4D4D),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
          );
  }
}
