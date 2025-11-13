import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukk_tedii/models/company_model.dart';
import 'api_service.dart';

class UserService {
  /// Get current logged in user's company information
  Future<Company?> getMyCompany() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      // Try multiple endpoints
      final endpoints = [
        '/my-company',
        '/company/me',
        '/companies/me',
        '/hrd/company',
      ];

      for (final endpoint in endpoints) {
        try {
          final url = Uri.parse('${ApiService.baseUrl}$endpoint');
          print('🔍 Trying endpoint: $endpoint');

          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
              'Authorization': 'Bearer $token',
            },
          );

          print('   Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            print('   Response: ${jsonData.keys.toList()}');
            
            if (jsonData['success'] == true && jsonData['data'] != null) {
              print('✅ Found working endpoint: $endpoint');
              return Company.fromJson(jsonData['data']);
            }
          }
        } catch (e) {
          print('   Error: $e');
          continue;
        }
      }
      
      print('❌ No working endpoint found for company data');
      return null;
    } catch (e) {
      print('Error getting my company: $e');
      return null;
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('${ApiService.baseUrl}/me');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'];
        }
        return null;
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
}
