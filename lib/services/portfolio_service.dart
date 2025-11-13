import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioService {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/jobsheeker';
  static const String appKey = 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2';
  final Dio _dio = Dio();

  /// Ambil semua portofolio berdasarkan UUID society
  Future<List<dynamic>> getPortfoliosByUUID(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('📤 Fetching portfolios for UUID: $uuid');
    print('🔑 Using token: $token');

    try {
      final response = await _dio.get(
        '$baseUrl/portofolios/society/$uuid', // ✅ perhatikan endpoint ini
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'APP-KEY': appKey,
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Portfolios retrieved successfully!');
        return response.data['data'];
      } else {
        print('⚠️ Unexpected response: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ Error fetching portfolios: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  /// Upload portofolio baru
  static Future<bool> createPortfolio({
    required String skill,
    required String description,
    required String societyUUID,
    required String token,
    required String filePath,
  }) async {
    try {
      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        'skill': skill,
        'description': description,
        'society_id': societyUUID,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await Dio().post(
        '$baseUrl/portofolios',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'APP-KEY': appKey,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📡 Upload Response: ${response.data}');
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('❌ Error creating portfolio: ${e.response?.data ?? e.message}');
      return false;
    }
  }
}
