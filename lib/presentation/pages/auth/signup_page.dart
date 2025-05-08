import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'login_page.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _image;

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/BSocial-1.png',
                        height: 80,
                      ),
                      UiConstants.kHeight30,

                      // Profile image picker
                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                )
                              : const CircleAvatar(
                                  radius: 64,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _selectImage,
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      UiConstants.kHeight30,

                      // Username field
                      CustomTextField(
                        controller: authProvider.usernameController,
                        hintText: 'Username',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      UiConstants.kHeight20,

                      // Email field
                      CustomTextField(
                        controller: authProvider.emailController,
                        hintText: 'Email',
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
                        hintText: 'Password',
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
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSignup(authProvider),
                      ),
                      UiConstants.kHeight30,

                      // Sign up button
                      CustomButton(
                        text: 'Sign Up',
                        onPressed: () => _handleSignup(authProvider),
                        isLoading: authProvider.status == AuthStatus.loading,
                      ),
                      UiConstants.kHeight30,

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          UiConstants.kWidth,
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    final pickedImage = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Image Source'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Take a photo'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Choose from gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    if (pickedImage != null) {
      final file = await ImageUtils.pickImage(pickedImage);
      if (file != null) {
        setState(() {
          _image = file;
        });
      }
    }
  }

  void _handleSignup(AuthProvider authProvider) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Check if image is selected
    if (_image == null) {
      SnackbarUtils.showSnackBar(
        'Please select a profile image',
        context,
      );
      return;
    }

    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      final success = await authProvider.signUp(
        username: authProvider.usernameController.text.trim(),
        email: authProvider.emailController.text.trim(),
        password: authProvider.passwordController.text,
        file: _image,
      );

      if (!mounted) return;

      if (!success && context.mounted) {
        authProvider.showErrorSnackBar(context);
      }
    }
  }
}
