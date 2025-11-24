import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Initialize auth state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        await getCurrentUser();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        location: location,
      );

      _isLoading = false;
      notifyListeners();
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔑 AuthProvider: Starting login for $email...');
      
      _user = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      _isAuthenticated = true;
      _isLoading = false;
      
      print('✅ AuthProvider: Login successful!');
      print('👤 Current user: ${_user!.name} (ID: ${_user!.id})');
      
      notifyListeners();
      
      // CRITICAL: Wait to ensure token is fully saved before UI updates
      await Future.delayed(const Duration(milliseconds: 300));
      
      return true;
    } catch (e) {
      print('❌ AuthProvider: Login failed - $e');
      _errorMessage = _getErrorMessage(e);
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyEmail(token);
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

  // Resend verification email
  Future<bool> resendVerification(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resendVerification(email);
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

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
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

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(token: token, password: password);
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

  // Get current user
  Future<void> getCurrentUser() async {
    try {
      _user = await _authService.getCurrentUser();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    print('🚪 AuthProvider: Logging out user ${_user?.name} (ID: ${_user?.id})...');
    
    // Store old user ID for logging
    final oldUserId = _user?.id;
    final oldUserName = _user?.name;
    
    // CRITICAL: Clear state first to signal logout
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    
    // Notify listeners BEFORE logout to trigger widget disposal
    notifyListeners();
    
    // Wait a bit for widgets to respond
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Then clear storage - this removes token and all cached user data
    await _authService.logout();
    
    // Wait a bit more to ensure storage is fully cleared
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Verify cleanup
    final token = await _authService.isLoggedIn();
    if (token) {
      print('⚠️ WARNING: Token still exists after logout!');
    }
    
    print('✅ AuthProvider: User logged out, auth state cleared (was: $oldUserName, ID: $oldUserId)');
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper to get error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('DioException')) {
      // Handle Dio errors
      return 'Network error. Please check your connection.';
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}

