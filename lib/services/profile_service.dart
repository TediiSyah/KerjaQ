import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';
  static const String _profileImagePathKey = 'profile_image_path';
  static const String _cvFilePathKey = 'cv_file_path';
  static const String _cvFileNameKey = 'cv_file_name';
  static const String _portfolioFilePathKey = 'portfolio_file_path';
  static const String _portfolioFileNameKey = 'portfolio_file_name';

  // Save profile data
  static Future<void> saveProfile({
    required String name,
    required String email,
    String? profileImagePath,
    String? cvFilePath,
    String? cvFileName,
    String? portfolioFilePath,
    String? portfolioFileName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);

    if (profileImagePath != null) {
      await prefs.setString(_profileImagePathKey, profileImagePath);
    }

    if (cvFilePath != null) {
      await prefs.setString(_cvFilePathKey, cvFilePath);
    }

    if (cvFileName != null) {
      await prefs.setString(_cvFileNameKey, cvFileName);
    }

    if (portfolioFilePath != null) {
      await prefs.setString(_portfolioFilePathKey, portfolioFilePath);
    }

    if (portfolioFileName != null) {
      await prefs.setString(_portfolioFileNameKey, portfolioFileName);
    }
  }

  // Load profile data
  static Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(_nameKey),
      'email': prefs.getString(_emailKey),
      'profileImagePath': prefs.getString(_profileImagePathKey),
      'cvFilePath': prefs.getString(_cvFilePathKey),
      'cvFileName': prefs.getString(_cvFileNameKey),
      'portfolioFilePath': prefs.getString(_portfolioFilePathKey),
      'portfolioFileName': prefs.getString(_portfolioFileNameKey),
    };
  }

  // Clear profile data
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_profileImagePathKey);
    await prefs.remove(_cvFilePathKey);
    await prefs.remove(_cvFileNameKey);
    await prefs.remove(_portfolioFilePathKey);
    await prefs.remove(_portfolioFileNameKey);
  }
}
