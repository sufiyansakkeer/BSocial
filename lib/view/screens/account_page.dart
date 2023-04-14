import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/view/screens/privacy_policy.dart';
import 'package:bsocial/view/screens/terms_and_condition.dart';

import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings Page"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const TermsAndCondition(),
              ));
            },
            title: const Text("Terms and Condition"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PrivacyPolicy(),
              ));
            },
            title: const Text("Privacy and Policy"),
          ),
        ],
      ),
    );
  }
}
