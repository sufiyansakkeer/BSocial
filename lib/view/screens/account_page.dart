import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/terms_and_condition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings Page"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {},
            title: Text("Edit Profile"),
          ),
          ListTile(
            onTap: () {},
            title: Text("About"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TermsAndCondition(),
              ));
            },
            title: Text("Terms and Condition"),
          ),
          ListTile(
            onTap: () {},
            title: Text("Privacy and Policy"),
          ),
        ],
      ),
    );
  }
}
