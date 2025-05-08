import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.status == AuthStatus.loading;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
              onTap: isLoading
                  ? null
                  : () => _handleGoogleSignIn(context, authProvider),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      Image.asset(
                        'assets/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      isLoading ? 'Signing in...' : 'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
