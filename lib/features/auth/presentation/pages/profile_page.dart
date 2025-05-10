import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/auth_bloc.dart';
import '../widgets/profile_menu_item.dart';

/// Profile page
class ProfilePage extends StatefulWidget {
  /// Constructor
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _statusController = TextEditingController();
  Uint8List? _selectedImage;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      _usernameController.text = state.user.userName;
      _statusController.text = state.user.status;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initUserData();
        _selectedImage = null;
      }
    });
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateProfileEvent(
              userName: _usernameController.text.trim(),
              profileImage: _selectedImage,
              status: _statusController.text.trim(),
            ),
          );
    }
  }

  void _navigateToChangePassword() {
    context.push('/auth/change-password');
  }

  void _toggleMfa() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      if (state.user.isMfaEnabled) {
        // Show dialog to confirm MFA disablement
        showDialog(
          context: context,
          builder: (context) => _buildDisableMfaDialog(),
        );
      } else {
        // Enable MFA
        context.read<AuthBloc>().add(EnableMfaEvent());
      }
    }
  }

  Widget _buildDisableMfaDialog() {
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text('Disable Two-Factor Authentication'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'For security reasons, please enter your password to disable '
            'two-factor authentication.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(
                  DisableMfaEvent(
                    password: passwordController.text.trim(),
                  ),
                );
          },
          child: const Text('Disable'),
        ),
      ],
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteAccountDialog(),
    );
  }

  Widget _buildDeleteAccountDialog() {
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This action cannot be undone. All your data will be permanently'
            ' deleted. Please enter your password to confirm.',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(
                  DeleteAccountEvent(
                    password: passwordController.text.trim(),
                  ),
                );
          },
          child: const Text('Delete Account'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _toggleEditMode,
              )
            else
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleEditMode,
              ),
          ],
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _isEditing = false;
              });
            } else if (state is MfaEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MfaDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AccountDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/auth/login');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_isEditing)
                    _buildEditProfileForm(user)
                  else
                    _buildProfileInfo(user),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildSecuritySettings(user),
                ],
              ),
            );
          },
        ),
      );

  Widget _buildProfileInfo(user) => Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.photoUrl),
          ),
          const SizedBox(height: 16),
          Text(
            user.userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${user.status}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Role: ${user.role.toString().split('.').last}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (user.isEmailVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    user.followers.length.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Followers'),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  Text(
                    user.following.length.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Following'),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _buildEditProfileForm(user) => Form(
        key: _formKey,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? MemoryImage(_selectedImage!)
                      : NetworkImage(user.photoUrl) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: _selectImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      );

  Widget _buildSecuritySettings(user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: _navigateToChangePassword,
          ),
          ProfileMenuItem(
            icon: Icons.security,
            title: user.isMfaEnabled
                ? 'Disable Two-Factor Authentication'
                : 'Enable Two-Factor Authentication',
            onTap: _toggleMfa,
          ),
          if (!user.isEmailVerified)
            ProfileMenuItem(
              icon: Icons.mark_email_read,
              title: 'Verify Email',
              onTap: () {
                context.read<AuthBloc>().add(SendEmailVerificationEvent());
              },
            ),
          const Divider(),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () {
              context.read<AuthBloc>().add(const SignOutEvent());
            },
          ),
          ProfileMenuItem(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            color: Colors.red,
            onTap: _deleteAccount,
          ),
        ],
      );
}
