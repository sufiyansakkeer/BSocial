import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return StreamBuilder(
      // here we use snapshot instead of get , because get will return a future function
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy("datePublished", descending: true)
          .snapshots(),
      // initialData: initialData,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Image.asset(
                "assets/BSocial-1.png",
                height: MediaQuery.of(context).size.height * 0.035,
              ),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.messenger,
                  ),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return PostCard(snap: snapshot.data!.docs[index].data());
              },
            ),
          );
        }
      },
    );
  }
}
