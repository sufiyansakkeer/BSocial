import 'dart:typed_data';

import 'package:bsocial/model/user_model.dart';
import 'package:bsocial/provider/post_image_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.of<PostImageProvider>(context).file == null
        ? SafeArea(
            child: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Consumer<PostImageProvider>(
                        builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: () {
                          provider.selectImage(context);
                        },
                        child: const Icon(
                          Icons.add_box_rounded,
                          size: 100,
                        ),
                      );
                    }),
                  ),
                  const Text('Click Add button to add Post')
                ],
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 0,
              leading:
                  Consumer<PostImageProvider>(builder: (context, value, child) {
                return IconButton(
                  onPressed: () {
                    value.clearImage();
                  },
                  icon: Icon(
                    Icons.adaptive.arrow_back,
                  ),
                );
              }),
              title: const Text('Post to'),
              actions: [
                Consumer<PostImageProvider>(builder: (context, value, child) {
                  return TextButton(
                    onPressed: () {
                      // value.removeImage();
                      // Navigator.of(context).pop();
                      final UserModel userModel =
                          Provider.of<UsersProvider>(context, listen: false)
                              .getUser;
                      value.postImage(
                        userModel.uid,
                        userModel.userName,
                        userModel.photoUrl,
                        context,
                      );
                      value.disposeController();
                      value.clearImage();
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }),
              ],
            ),
            body: Column(
              children: [
                Provider.of<PostImageProvider>(context).isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.all(
                          0,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<UsersProvider>(
                        builder: (context, provider, child) {
                      return CircleAvatar(
                        backgroundImage:
                            NetworkImage(provider.getUser.photoUrl),
                      );
                    }),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Consumer<PostImageProvider>(
                          builder: (context, value, child) {
                        return TextField(
                          controller: value.descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption....',
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        );
                      }),
                    ),
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Consumer<PostImageProvider>(
                            builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: MemoryImage(value.file!),
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.center),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ));
  }
}
