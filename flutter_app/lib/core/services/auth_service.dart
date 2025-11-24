import '../constants/api_constants.dart';
import '../../data/models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final _api = ApiService();
  final _storage = StorageService();

  // Sign up
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? location,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          if (location != null && location.isNotEmpty) 'location': location,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Signup failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔐 Logging in as: $email');
      
      // CRITICAL: Clear any existing user data before login to prevent stale data
      print('🧹 Clearing any existing user data before login...');
      await _storage.clearUserData();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final response = await _api.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final userData = data['user'];

        print('✅ Login successful for user: ${userData['name']} (ID: ${userData['id']})');
        print('📝 Saving new token and user data for this user...');
        
        // CRITICAL: Save token and user data - ensure fresh data
        await _storage.saveToken(token);
        await _storage.saveUserId(userData['id']);
        await _storage.saveUserEmail(userData['email']);
        await _storage.saveUserName(userData['name']);
        await _storage.saveRememberMe(rememberMe);
        
        // Verify data was saved correctly
        final savedUserId = _storage.getUserId();
        final savedToken = await _storage.getToken();
        if (savedUserId == userData['id'] && savedToken != null) {
          print('✅ Token and user data saved and verified successfully');
        } else {
          print('⚠️ WARNING: Saved user data verification failed!');
          print('   Expected userId: ${userData['id']}, Got: $savedUserId');
          print('   Token exists: ${savedToken != null}');
        }

        return UserModel.fromJson(userData);
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // Verify email
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _api.get(
        ApiConstants.verifyEmail,
        queryParameters: {'token': token},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await _api.post(
        ApiConstants.resendVerification,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to resend verification email');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _api.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to send reset email');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(ApiConstants.getMe);

      if (response.statusCode == 200) {
        final userData = response.data['data']['user'];
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  Future<void> logout() async {
    print('🚪 Logging out - clearing all user data and tokens...');
    await _storage.clearUserData();
    print('✅ User data cleared successfully');
  }
}

