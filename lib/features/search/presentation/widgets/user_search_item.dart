import 'package:flutter/material.dart';

import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Widget that displays a user search result item
class UserSearchItem extends StatelessWidget {
  /// Constructor
  const UserSearchItem({
    required this.user,
    required this.onTap,
    this.searchQuery = '',
    super.key,
  });

  /// User
  final User user;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Search query for highlighting
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: ImageWidgetExtensions.safeCircleAvatar(
        imageUrl: user.photoUrl,
        radius: 20,
      ),
      title: _buildHighlightedText(
        user.userName,
        searchQuery,
        theme.textTheme.titleMedium!,
        theme.colorScheme.primary,
      ),
      subtitle: _buildHighlightedText(
        user.email,
        searchQuery,
        theme.textTheme.bodySmall!,
        theme.colorScheme.primary,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: UiConstants.paddingH16V8,
      onTap: onTap,
    );
  }

  /// Build text with highlighted search query
  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle style,
    Color highlightColor,
  ) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    if (!lowerCaseText.contains(lowerCaseQuery)) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    var start = 0;
    int indexOfMatch;

    while (true) {
      indexOfMatch = lowerCaseText.indexOf(lowerCaseQuery, start);
      if (indexOfMatch == -1) {
        // No more matches
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (start < indexOfMatch) {
        // Add text before match
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: style.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = indexOfMatch + query.length;
    }

    return RichText(text: TextSpan(style: style, children: spans));
  }
}
