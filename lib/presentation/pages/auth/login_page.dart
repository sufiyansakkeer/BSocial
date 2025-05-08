import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/animation_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/auth/google_sign_in_button.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clear any previous form data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearFormFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: UiConstants.paddingH24,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AnimationUtils.staggeredList(
                      initialDelay: const Duration(milliseconds: 100),
                      children: [
                        // Logo with animation
                        Hero(
                          tag: 'app_logo',
                          child: AnimationUtils.scale(
                            begin: 0.8,
                            end: 1.0,
                            duration: UiConstants.animSlow,
                            curve: UiConstants.animCurveEmphasized,
                            child: Image.asset(
                              'assets/BSocial-1.png',
                              height: 120,
                            ),
                          ),
                        ),
                        UiConstants.kHeight40,

                        // Welcome text
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        UiConstants.kHeight8,
                        Text(
                          'Sign in to continue',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                        UiConstants.kHeight30,

                        // Email field
                        CustomTextField(
                          controller: authProvider.emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        UiConstants.kHeight20,

                        // Password field
                        CustomTextField(
                          controller: authProvider.passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          isPassword: !authProvider.isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: authProvider.togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(authProvider),
                        ),
                        UiConstants.kHeight8,

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset coming soon!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        UiConstants.kHeight20,

                        // Login button
                        CustomButton(
                          text: 'Login',
                          icon: Icons.login,
                          onPressed: () => _handleLogin(authProvider),
                          isLoading: authProvider.status == AuthStatus.loading,
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        UiConstants.kHeight24,

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.dividerColor)),
                            Padding(
                              padding: UiConstants.paddingH16,
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(150),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.dividerColor)),
                          ],
                        ),
                        UiConstants.kHeight24,

                        // Google sign in button
                        const GoogleSignInButton(),
                        UiConstants.kHeight30,

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                            UiConstants.kWidth8,
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SignupPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: UiConstants.animMedium,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      final success = await authProvider.login(
        email: authProvider.emailController.text.trim(),
        password: authProvider.passwordController.text,
      );

      if (!mounted) return;

      if (!success && context.mounted) {
        authProvider.showErrorSnackBar(context);
      }
    }
  }
}
