import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Keys for SharedPreferences
  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _companyIdKey = 'company_id';
  static const String _companyNameKey = 'company_name';
  static const String _companyAddressKey = 'company_address';

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  /// Get user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get user role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Check if current user is HRD
  static Future<bool> isHRD() async {
    final role = await getRole();
    return role == 'HRD';
  }

  /// Check if current user is Society
  static Future<bool> isSociety() async {
    final role = await getRole();
    return role == 'SOCIETY';
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Get company ID (for HRD users)
  static Future<String?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyIdKey);
  }

  /// Get company name (for HRD users)
  static Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey);
  }

  /// Get company address (for HRD users)
  static Future<String?> getCompanyAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyAddressKey);
  }

  /// Get all user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'role': prefs.getString(_roleKey),
      'user_id': prefs.getString(_userIdKey),
      'user_name': prefs.getString(_userNameKey),
      'user_email': prefs.getString(_userEmailKey),
    };
  }

  /// Get all company data (for HRD users)
  static Future<Map<String, String?>> getCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'company_id': prefs.getString(_companyIdKey),
      'company_name': prefs.getString(_companyNameKey),
      'company_address': prefs.getString(_companyAddressKey),
    };
  }

  /// Clear all session data (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_companyIdKey);
    await prefs.remove(_companyNameKey);
    await prefs.remove(_companyAddressKey);
  }

  /// Save session data
  static Future<void> saveSession({
    required String token,
    required String role,
    String? userId,
    String? userName,
    String? userEmail,
    String? companyId,
    String? companyName,
    String? companyAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    
    if (userId != null) await prefs.setString(_userIdKey, userId);
    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);
    if (companyId != null) await prefs.setString(_companyIdKey, companyId);
    if (companyName != null) await prefs.setString(_companyNameKey, companyName);
    if (companyAddress != null) await prefs.setString(_companyAddressKey, companyAddress);
  }
}
