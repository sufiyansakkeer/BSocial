import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../providers/auth/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return OutlinedButton(
          onPressed: authProvider.status == AuthStatus.loading
              ? null
              : () => _handleGoogleSignIn(context, authProvider),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn(
      BuildContext context, AuthProvider authProvider) async {
    try {
      final success = await authProvider.signInWithGoogle();

      if (!context.mounted) return;

      if (!success) {
        SnackbarUtils.showSnackBar(
          authProvider.errorMessage,
          context,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      SnackbarUtils.showSnackBar(
        'Failed to sign in with Google: ${e.toString()}',
        context,
      );
    }
  }
}
