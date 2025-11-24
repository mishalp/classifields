import 'package:flutter/material.dart';
import '../core/services/post_service.dart';
import '../core/services/location_service.dart';
import '../data/models/post_model.dart';
import 'package:geolocator/geolocator.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final LocationService _locationService = LocationService();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  Position? _currentPosition;
  
  // Search and filter state
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortOption = 'newest'; // Default sort
  
  // For post details
  PostModel? _selectedPost;
  bool _isLoadingDetails = false;
  bool _isOwnPost = false;
  
  // For my posts
  List<PostModel> _myPosts = [];
  bool _isLoadingMyPosts = false;
  String? _myPostsErrorMessage;
  Map<String, int> _myPostsStatusCounts = {};
  
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  Position? get currentPosition => _currentPosition;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String get sortOption => _sortOption;
  
  PostModel? get selectedPost => _selectedPost;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isOwnPost => _isOwnPost;
  
  List<PostModel> get myPosts => _myPosts;
  bool get isLoadingMyPosts => _isLoadingMyPosts;
  String? get myPostsErrorMessage => _myPostsErrorMessage;
  Map<String, int> get myPostsStatusCounts => _myPostsStatusCounts;

  // Load nearby posts with search and category filters
  Future<void> loadNearbyPosts({
    double radius = 10.0,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _isLoading = true;
      _errorMessage = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Unable to get your location');
      }

      _currentPosition = position;

      // Fetch posts with search, category filters, and sorting
      final posts = await _postService.getNearbyPosts(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: radius,
        limit: limit,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory,
        sort: _sortOption,
      );

      _posts = posts;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('Error loading posts: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Set search query and reload posts
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();
    await loadNearbyPosts(refresh: true);
  }

  // Set category filter and reload posts
  Future<void> setCategory(String? category) async {
    _selectedCategory = category;
    notifyListeners();
    await loadNearbyPosts(refresh: true);
  }

  // Set sort option and reload posts
  Future<void> setSortOption(String sortOption) async {
    _sortOption = sortOption;
    notifyListeners();
    await loadNearbyPosts(refresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategory = null;
    _sortOption = 'newest'; // Reset to default sort
    notifyListeners();
    await loadNearbyPosts(refresh: true);
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadNearbyPosts(refresh: true);
  }

  // Create post
  Future<bool> createPost({
    required String title,
    required String description,
    required double price,
    required String category,
    String? address,
    List<String>? images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Unable to get your location');
      }

      await _postService.createPost(
        title: title,
        description: description,
        price: price,
        category: category,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        images: images,
      );

      // Refresh posts after creating
      await refreshPosts();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper to get error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Location')) {
      return 'Location access is required to show nearby posts';
    }
    if (error.toString().contains('DioException')) {
      return 'Network error. Please check your connection.';
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  // Fetch post details by ID
  Future<void> fetchPostDetails(String postId) async {
    _isLoadingDetails = true;
    _selectedPost = null;
    _isOwnPost = false;
    notifyListeners();

    try {
      final response = await _postService.getPostById(postId);
      _selectedPost = response['post'];
      _isOwnPost = response['isOwnPost'] ?? false;
      _isLoadingDetails = false;
      notifyListeners();
    } catch (error) {
      _isLoadingDetails = false;
      _selectedPost = null;
      notifyListeners();
      print('Error fetching post details: $error');
    }
  }

  // Fetch user's own posts
  Future<void> fetchMyPosts(String status) async {
    _isLoadingMyPosts = true;
    _myPostsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _postService.getMyPosts(status);
      _myPosts = response['posts'];
      _myPostsStatusCounts = response['statusCounts'];
      _isLoadingMyPosts = false;
      notifyListeners();
    } catch (error) {
      _isLoadingMyPosts = false;
      _myPostsErrorMessage = _getErrorMessage(error);
      notifyListeners();
      print('Error fetching my posts: $error');
    }
  }

  // Clear selected post
  void clearSelectedPost() {
    _selectedPost = null;
    _isOwnPost = false;
    notifyListeners();
  }
}

