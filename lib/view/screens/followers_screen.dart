import 'package:bsocial/provider/followers_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/profile_screen/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key, required this.userUid});
  final String userUid;

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  void initState() {
    Provider.of<FollowerProvider>(context, listen: false)
        .getUserFollowers(userUid: widget.userUid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          "Followers",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("users").get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Consumer<FollowerProvider>(
                builder: (context, provider, child) {
              return provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: provider.userModelList!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    uid: provider.userModelList![index].uid,
                                  ),
                                ),
                              );
                            },
                            title: Text(
                              provider.userModelList![index].userName,
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                provider.userModelList![index].photoUrl,
                              ),
                            ),
                          ),
                        );
                      },
                    );
            });
          },
        ),
      ),
    );
  }
}
