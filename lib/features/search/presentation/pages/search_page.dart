import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/search_bloc.dart';
import '../widgets/recent_search_item.dart';
import '../widgets/user_search_item.dart';

/// Page for searching users
class SearchPage extends StatefulWidget {
  /// Constructor
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Debounce timer for search
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();

    // Load recent searches when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(LoadRecentSearchesEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Search for users with debounce
  void _search(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchBloc>().add(SearchUsersEvent(query: query));
    });
  }

  /// Clear search results
  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(ClearSearchEvent());
  }

  /// Use a recent search
  void _useRecentSearch(String query) {
    _searchController.text = query;
    context.read<SearchBloc>().add(UseRecentSearchEvent(query: query));
  }

  /// Clear all recent searches
  void _clearRecentSearches() {
    context.read<SearchBloc>().add(ClearRecentSearchesEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search for users...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
            ),
            onChanged: _search,
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return _buildRecentSearches(state);
            } else if (state is SearchLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SearchResults) {
              if (state.users.isEmpty) {
                return Center(
                  child: Text('No users found for "${state.query}"'),
                );
              }

              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return UserSearchItem(
                    user: user,
                    searchQuery: state.query,
                    onTap: () {
                      context.go('/profile/${user.uid}');
                    },
                  );
                },
              );
            } else if (state is SearchError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _search(_searchController.text),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },
        ),
      );

  /// Build the recent searches UI
  Widget _buildRecentSearches(SearchInitial state) {
    if (state.recentSearches.isEmpty) {
      return const Center(
        child: Text('Search for users by username or email'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.recentSearches.length,
            itemBuilder: (context, index) {
              final search = state.recentSearches[index];
              return RecentSearchItem(
                search: search,
                onTap: () => _useRecentSearch(search.query),
                onDelete: _clearRecentSearches,
              );
            },
          ),
        ),
      ],
    );
  }
}
