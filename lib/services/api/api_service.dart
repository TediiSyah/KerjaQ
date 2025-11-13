import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/jobsheeker';
  static const String appKey = 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'APP-KEY': appKey,
      },
    ),
  );

  // 🔹 Ambil semua lowongan aktif
  Future<List<dynamic>> getActivePositions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _dio.get(
      '/available-positions/active',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }

  // 🔹 Apply ke lowongan (Society)
  Future<Response> applyToPosition(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return _dio.post(
      '/position-applied',
      data: jsonEncode({"available_position_id": uuid}),
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'APP-KEY': appKey,
      }),
    );
  }

  // 🔹 Ambil riwayat lamaran milik user (Society)
  Future<List<dynamic>> getMyApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _dio.get(
      '/position-applied/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }

  // 🔹 Ambil semua lamaran yang masuk (HRD)
  Future<List<dynamic>> getIncomingApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _dio.get(
      '/position-applied?page=1&quantity=100',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'] ?? [];
  }

  // 🔹 Update status lamaran (ACCEPTED / REJECTED)
  Future<Response> updateApplicationStatus(String uuid, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return _dio.patch(
      '/position-applied/$uuid',
      data: jsonEncode({'status': status}),
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'APP-KEY': appKey,
      }),
    );
  }
}
