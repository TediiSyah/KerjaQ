import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://learn.smktelkom-mlg.sch.id/jobsheeker";
  final String appKey = "d11869cbb24234949e1d47e131adbd7c6fc6d6b2";

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String dateOfBirth,
    required String address,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {
          "Content-Type": "application/json",
          "APP-KEY": appKey,
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": name,
          "phone": phone,
          "date_of_birth": dateOfBirth,
          "address": address,
          "gender": gender,
        }),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "Registrasi berhasil"};
      } else {
        final body = jsonDecode(response.body);

        if (body["message"]?.toString().contains("already") == true) {
          return {
            "success": false,
            "message": "Email, username, atau nomor sudah terdaftar"
          };
        }

        return {
          "success": false,
          "message": body["message"] ?? "Gagal registrasi"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {
          "Content-Type": "application/json",
          "APP-KEY": appKey,
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: $data");

      if (response.statusCode == 201 && data["success"] == true) {
        return {
          "success": true,
          "token": data["token"],
          "role": data["role"],
        };
      } else {
        return {"success": false, "message": data["message"] ?? "Login gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
}
