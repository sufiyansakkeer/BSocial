import 'package:bsocial/utils/colors.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("Privacy Policy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const [
            Text(
              "At BSocial, we take privacy very seriously and are committed to protecting the personal information of our users. This privacy policy explains how we collect, use, and disclose personal information when you use our social media application.\n\n1. Information we collect:\n\n• Personal Information: We collect information that can identify you, such as your name, email address, and phone number, when you create an account with us.\n• Profile Information: We also collect information you provide when you create a profile, such as your profile picture, bio, and location.\n• Activity Information: We collect information about your activity on our app, such as the content you post, the people you follow, and the messages you send.\n• Device Information: We collect information about the device you use to access our app, such as your device model, operating system, and IP address.\n\n2. How we use your information:\n\n• To provide and improve our services: We use your information to provide and improve our app, including customizing content, providing recommendations, and offering new features.\n• To communicate with you: We may use your email address to send you updates and notifications about our app.\n• To personalize your experience: We use your information to personalize your experience on our app, such as showing you content that is relevant to your interests.\n• To analyze and improve our app: We use your information to analyze how our app is being used and to identify areas for improvement.\n\n3. How we share your information:\n\n• With third-party service providers: We may share your information with third-party service providers that help us provide and improve our app, such as hosting and data analytics providers.\n• With other users: When you post content on our app, it may be visible to other users of the app.\n• With law enforcement and government agencies: We may share your information with law enforcement and government agencies when required by law or in response to a legal request.\n\n4. How we protect your information:\n\nWe use reasonable and appropriate measures to protect your personal information from unauthorized access, disclosure, and use. However, no data transmission over the internet or electronic storage can be guaranteed to be 100% secure.\n\n5. Your choices:\n\n• You can choose not to provide us with certain information, but this may limit your ability to use certain features of our app.\n• You can choose to delete your account and the information associated with it at any time.\n\n6. Changes to this privacy policy:\n\nWe may update this privacy policy from time to time. We will notify you of any material changes to this policy by email or by posting a notice on our app.\nIf you have any questions or concerns about our privacy policy, please contact us at support@bsocial.com.",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
