import 'package:flutter/material.dart';

/// Profile menu item widget
class ProfileMenuItem extends StatelessWidget {
  /// Constructor
  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.color,
  });

  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Callback when tapped
  final VoidCallback onTap;

  /// Optional color for the icon and text
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
