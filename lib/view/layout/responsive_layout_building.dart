import 'package:bsocial/core/size.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout(
      {super.key,
      required this.webScreenLayout,
      required this.mobileScreenLayout});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<UsersProvider>(context, listen: false).refreshUi();
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenHeight) {
          //webScreen Layout
          return webScreenLayout;
        } else {
          return mobileScreenLayout;
        }
      },
    );
  }
}
