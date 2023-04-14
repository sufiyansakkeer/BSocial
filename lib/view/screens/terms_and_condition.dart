import 'package:bsocial/utils/colors.dart';
import 'package:flutter/material.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text("Term's and Conditions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const [
            Text(
              "Terms and Conditions for bSocial Social Media App\n\nWelcome to bSocial! These Terms and Conditions ('AgreementsemanticsLabel: ') govern your use of the bSocial social media application ('App'). By using the App, you agree to comply with and be bound by this Agreement, as well as all applicable laws and regulations.\n1. User Eligibility\nYou must be 13 years or older to use the App. By using the App, you represent that you are at least 13 years of age.\n\n2. User Accounts\nYou are responsible for maintaining the confidentiality of your bSocial account login information. You are responsible for all activities that occur under your account, and you agree to notify bSocial immediately of any unauthorized use of your account.\n\n3. User Content\nYou are solely responsible for the content that you post on the App. You agree not to post content that is unlawful, defamatory, harassing, or otherwise objectionable. You also agree not to post content that infringes on the intellectual property rights of any third party.\n\n4. User Conduct\nYou agree to use the App only for lawful purposes and in a manner that does not interfere with the use and enjoyment of the App by other users. You agree not to engage in any activity that could damage, disable, or impair the App, its servers, or its networks.\n\n5. Intellectual Property\nAll content on the App, including but not limited to text, graphics, logos, button icons, images, audio clips, and software, is the property of bSocial or its licensors and is protected by United States and international copyright laws.\n\n6. Termination\nbSocial reserves the right to terminate your access to the App at any time, for any reason or no reason, without notice.\n\n7. Disclaimer of Warranties\nThe App is provided 'as is' and bSocial makes no warranties, express or implied, regarding the App, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.\n\n8. Limitation of Liability\nIn no event shall bSocial be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in connection with the use or inability to use the App, even if bSocial has been advised of the possibility of such damages.\n\n9. Governing Law\nThis Agreement shall be governed by and construed in accordance with the laws of the State of California.\n\n10. Changes to this Agreement\nbSocial reserves the right to change this Agreement at any time. Your continued use of the App after any such changes constitutes your acceptance of the new Agreement.\n\n11. Entire Agreement\nThis Agreement constitutes the entire agreement between you and bSocial with respect to the App and supersedes all prior or contemporaneous communications and proposals, whether oral or written, between you and bSocial.\n\nIf you have any questions about this Agreement, please contact us at support@bsocial.com.",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
