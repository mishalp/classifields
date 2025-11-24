import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../data/models/post_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class PostService {
  final _api = ApiService();
  final _storage = StorageService();

  // Helper to get content type based on file extension
  MediaType _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default to jpeg
    }
  }

  // Upload images
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Prepare multipart request
      final uri = Uri.parse('${ApiConstants.baseUrl}/posts/upload-images');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add images with correct content type
      for (var image in images) {
        // Determine content type based on file extension
        final extension = image.path.split('.').last.toLowerCase();
        final contentType = _getContentType(extension);
        
        final file = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: contentType,
        );
        request.files.add(file);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(
          json.decode(response.body) as Map,
        );
        final List<dynamic> imagesList = data['data']['images'] ?? [];
        return imagesList.map((url) => url.toString()).toList();
      } else {
        throw Exception('Failed to upload images');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby posts with search, category filters, and sorting
  Future<List<PostModel>> getNearbyPosts({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
    String? search,
    String? category,
    String? sort,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
        'limit': limit,
      };

      // Add optional filters
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final response = await _api.get(
        '${ApiConstants.baseUrl}/posts/nearby',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<dynamic> postsJson = data['posts'] ?? [];
        return postsJson.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch posts');
      }
    } catch (e) {
      rethrow;
    }
  }


  // Create post
  Future<PostModel> createPost({
    required String title,
    required String description,
    required double price,
    required String category,
    required double latitude,
    required double longitude,
    String? address,
    List<String>? images,
  }) async {
    try {
      final response = await _api.post(
        '${ApiConstants.baseUrl}/posts/create',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'lat': latitude,
          'lng': longitude,
          if (address != null) 'address': address,
          if (images != null) 'images': images,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return PostModel.fromJson(data['post']);
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      rethrow;
    }
  }


  // Update post
  Future<PostModel> updatePost({
    required String postId,
    String? title,
    String? description,
    double? price,
    String? category,
    String? status,
    List<String>? images,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (category != null) data['category'] = category;
      if (status != null) data['status'] = status;
      if (images != null) data['images'] = images;

      final response = await _api.put(
        '${ApiConstants.baseUrl}/posts/$postId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return PostModel.fromJson(responseData['post']);
      } else {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      final response = await _api.delete('${ApiConstants.baseUrl}/posts/$postId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get post by ID (Ad Details)
  Future<Map<String, dynamic>> getPostById(String postId) async {
    try {
      final response = await _api.get('${ApiConstants.baseUrl}/posts/$postId');

      if (response.statusCode == 200) {
        final data = response.data; // Dio already parses JSON
        
        if (data['success'] == true && data['data'] != null) {
          return {
            'post': PostModel.fromJson(data['data']['post']),
            'isOwnPost': data['data']['isOwnPost'] ?? false,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch post details');
        }
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user's own posts
  Future<Map<String, dynamic>> getMyPosts(String status) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _api.get(
        '${ApiConstants.baseUrl}/posts/my-posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data; // Dio already parses JSON
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> postsList = data['data']['posts'] ?? [];
          final Map<String, dynamic> statusCountsData =
              data['data']['statusCounts'] ?? {};

          final List<PostModel> posts =
              postsList.map((json) => PostModel.fromJson(json)).toList();

          final Map<String, int> statusCounts = {
            'all': statusCountsData['all'] ?? 0,
            'pending': statusCountsData['pending'] ?? 0,
            'approved': statusCountsData['approved'] ?? 0,
            'rejected': statusCountsData['rejected'] ?? 0,
          };

          return {
            'posts': posts,
            'statusCounts': statusCounts,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch my posts');
        }
      } else {
        throw Exception('Failed to fetch my posts');
      }
    } catch (e) {
      rethrow;
    }
  }
}

