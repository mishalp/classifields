import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods (for sensitive data like tokens)
  Future<void> saveToken(String token) async {
    print('💾 Saving token: ${token.substring(0, 20)}...');
    await _secureStorage.write(key: StorageConstants.authToken, value: token);
    print('✅ Token saved to secure storage');
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: StorageConstants.authToken);
    if (token != null) {
      print('📖 Retrieved token from storage: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No token found in storage');
    }
    return token;
  }

  Future<void> deleteToken() async {
    print('🗑️ Deleting token from secure storage...');
    await _secureStorage.delete(key: StorageConstants.authToken);
    print('✅ Token deleted');
  }

  // Shared Preferences Methods (for non-sensitive data)
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(StorageConstants.userId, userId);
  }

  String? getUserId() {
    return _prefs?.getString(StorageConstants.userId);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(StorageConstants.userEmail, email);
  }

  String? getUserEmail() {
    return _prefs?.getString(StorageConstants.userEmail);
  }

  Future<void> saveUserName(String name) async {
    await _prefs?.setString(StorageConstants.userName, name);
  }

  String? getUserName() {
    return _prefs?.getString(StorageConstants.userName);
  }

  Future<void> saveRememberMe(bool value) async {
    await _prefs?.setBool(StorageConstants.rememberMe, value);
  }

  bool getRememberMe() {
    return _prefs?.getBool(StorageConstants.rememberMe) ?? false;
  }

  Future<void> saveIsFirstTime(bool value) async {
    await _prefs?.setBool(StorageConstants.isFirstTime, value);
  }

  bool getIsFirstTime() {
    return _prefs?.getBool(StorageConstants.isFirstTime) ?? true;
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString(StorageConstants.themeMode, mode);
  }

  String getThemeMode() {
    return _prefs?.getString(StorageConstants.themeMode) ?? 'light';
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // Clear user data but keep app preferences
  Future<void> clearUserData() async {
    print('🧹 Clearing all user data...');
    
    // CRITICAL: Clear secure storage (token) first
    await deleteToken();
    
    // CRITICAL: Clear all user-related SharedPreferences
    if (_prefs != null) {
      await _prefs!.remove(StorageConstants.userId);
      await _prefs!.remove(StorageConstants.userEmail);
      await _prefs!.remove(StorageConstants.userName);
      await _prefs!.remove(StorageConstants.rememberMe);
    }
    
    print('✅ All user data cleared from both secure storage and SharedPreferences');
    
    // Verify cleanup
    final token = await getToken();
    final userId = getUserId();
    final userEmail = getUserEmail();
    final userName = getUserName();
    
    if (token != null || userId != null || userEmail != null || userName != null) {
      print('⚠️ WARNING: Some user data still exists after cleanup!');
      print('   Token: ${token != null ? "EXISTS" : "null"}');
      print('   UserId: $userId');
      print('   UserEmail: $userEmail');
      print('   UserName: $userName');
    } else {
      print('✅ Verification: All user data successfully cleared');
    }
  }
}

