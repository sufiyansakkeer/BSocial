import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/ui_constants.dart';
import '../../data/models/recent_search_model.dart';

/// Widget that displays a recent search item
class RecentSearchItem extends StatelessWidget {
  /// Constructor
  const RecentSearchItem({
    required this.search,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  /// Recent search
  final RecentSearchModel search;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Callback when the delete button is tapped
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();
    
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(search.query),
      subtitle: Text(
        'Searched on ${dateFormat.format(search.timestamp)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: onDelete,
      ),
      contentPadding: UiConstants.paddingH16V8,
      onTap: onTap,
    );
  }
}
