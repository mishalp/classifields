import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post_card.dart';
import '../../core/services/location_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _locationService = LocationService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  // All available categories
  final List<String> _categories = [
    'All',
    'Electronics',
    'Furniture',
    'Vehicles',
    'Real Estate',
    'Fashion',
    'Books',
    'Sports',
    'Home & Garden',
    'Toys & Games',
    'Services',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    final postProvider = context.read<PostProvider>();
    await postProvider.loadNearbyPosts(refresh: true);
  }

  void _onSearchChanged(String query) {
    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Create new debounce timer (500ms delay)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final postProvider = context.read<PostProvider>();
      postProvider.setSearchQuery(query);
    });
  }

  Future<void> _handleLocationPermission() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (hasPermission) {
      await _loadPosts();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission is required'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                _locationService.openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Classifieds'),
            Text(
              authProvider.user?.location ?? 'Nearby',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(postProvider),
          
          // Category Filter Chips
          _buildCategoryFilter(postProvider),
          
          // Sort Options
          _buildSortBar(postProvider),
          
          // Feed List
          Expanded(
            child: _buildBody(postProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to create post and refresh when returning
          final result = await Navigator.pushNamed(context, '/create-post');
          // Refresh posts when returning from create post screen
          if (mounted && result == true) {
            await _loadPosts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSearchBar(PostProvider postProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search ads...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                suffixIcon: postProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          postProvider.setSearchQuery('');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.border.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          if (postProvider.searchQuery.isNotEmpty ||
              postProvider.selectedCategory != null) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {
                _searchController.clear();
                postProvider.clearFilters();
              },
              icon: const Icon(Icons.filter_list_off, size: 20),
              tooltip: 'Clear Filters',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(PostProvider postProvider) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isAll = category == 'All';
          final isSelected = isAll
              ? postProvider.selectedCategory == null
              : postProvider.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                postProvider.setCategory(isAll ? null : category);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border.withOpacity(0.4),
                width: isSelected ? 1.2 : 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar(PostProvider postProvider) {
    // Sort options with display names and icons
    final Map<String, Map<String, dynamic>> sortOptions = {
      'newest': {
        'label': 'Newest',
        'icon': Icons.access_time,
      },
      'nearest': {
        'label': 'Nearest',
        'icon': Icons.location_on,
      },
      'price_asc': {
        'label': 'Price: Low to High',
        'icon': Icons.arrow_upward,
      },
      'price_desc': {
        'label': 'Price: High to Low',
        'icon': Icons.arrow_downward,
      },
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Sort:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PopupMenuButton<String>(
              initialValue: postProvider.sortOption,
              onSelected: (value) {
                postProvider.setSortOption(value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sortOptions[postProvider.sortOption]!['icon'],
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        sortOptions[postProvider.sortOption]!['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => sortOptions.entries.map((entry) {
                final isSelected = postProvider.sortOption == entry.key;
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        entry.value['icon'],
                        size: 18,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.value['label'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PostProvider postProvider) {
    if (postProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (postProvider.errorMessage != null) {
      return _buildErrorState(postProvider.errorMessage!);
    }

    if (postProvider.posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await postProvider.refreshPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: postProvider.posts.length,
        itemBuilder: (context, index) {
          final post = postProvider.posts[index];
          return PostCard(
            post: post,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/post-details',
                arguments: post.id,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final postProvider = context.read<PostProvider>();
    final hasFilters = postProvider.searchQuery.isNotEmpty ||
        postProvider.selectedCategory != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.store_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Results Found' : 'No Posts Nearby',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters to find what you\'re looking for.'
                  : 'There are no active listings in your area right now. Be the first to post!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasFilters)
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  postProvider.clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  // Navigate to create post and refresh when returning
                  final result = await Navigator.pushNamed(context, '/create-post');
                  // Refresh posts when returning from create post screen
                  if (mounted && result == true) {
                    await _loadPosts();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Post'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final isLocationError = errorMessage.toLowerCase().contains('location');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isLocationError
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocationError ? Icons.location_off : Icons.error_outline,
                size: 60,
                color: isLocationError ? AppColors.warning : AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isLocationError ? 'Location Required' : 'Oops!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isLocationError) ...[
              ElevatedButton.icon(
                onPressed: _handleLocationPermission,
                icon: const Icon(Icons.location_on),
                label: const Text('Enable Location'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _locationService.openLocationSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _loadPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

