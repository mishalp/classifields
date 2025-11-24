class ApiConstants {
  // Base URL - Change this to your backend URL
  // For Android Emulator: http://10.0.2.2:5000/api
  // For iOS Simulator: http://localhost:5000/api
  // For Physical Device: http://YOUR_IP:5000/api (find with ipconfig/ifconfig)
  static const String baseUrl = 'http://172.20.10.2:5000/api';
  
  // Base URL without /api suffix (used for image URLs)
  static const String baseUrlNoApi = 'http://172.20.10.2:5000';
  
  // Auth Endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resendVerification = '/auth/resend-verification';
  static const String getMe = '/auth/me';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

