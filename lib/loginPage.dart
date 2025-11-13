import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukk_tedii/services/api/user_service.dart';
import 'hrd/hrdDashboard.dart';
import 'masyarakat/societyDashboard.dart';
import 'option.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    // Validate email format
    final email = emailController.text.trim();
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email tidak valid")),
      );
      return;
    }

    setState(() => isLoading = true);

    const appKey = "d11869cbb24234949e1d47e131adbd7c6fc6d6b2";

    try {
      // Try multiple base URL and endpoint combinations for login
      final baseUrls = [
        "https://learn.smktelkom-mlg.sch.id/jobsheeker/",
      ];

      final endpoints = ['login', 'auth', 'api/login', 'auth/login'];

      http.Response? response;

      for (final baseUrl in baseUrls) {
        for (final endpoint in endpoints) {
          try {
            print("Trying login: ${baseUrl}$endpoint");
            response = await http
                .post(
                  Uri.parse("${baseUrl}$endpoint"),
                  headers: {
                    "Content-Type": "application/json",
                    "APP-KEY": appKey,
                  },
                  body: jsonEncode({
                    "email": email,
                    "password": passwordController.text.trim(),
                  }),
                )
                .timeout(const Duration(seconds: 10));

            print("LOGIN STATUS: ${response.statusCode}");
            print("LOGIN BODY: ${response.body}");

            if (response.statusCode != 404 && response.statusCode != 500) {
              print("✅ Found working login API: ${baseUrl}$endpoint");
              break;
            } else {
              print("❌ ${response.statusCode} on login: ${baseUrl}$endpoint");
            }
          } catch (e) {
            print("❌ Error on login ${baseUrl}$endpoint: $e");
          }
        }
        if (response != null &&
            response.statusCode != 404 &&
            response.statusCode != 500) {
          break; // Found a working combination
        }
      }

      if (response == null ||
          response.statusCode == 404 ||
          response.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "❌ Tidak dapat terhubung ke server login. Periksa koneksi atau coba lagi nanti."),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      // Handle non-JSON responses (like 404 HTML pages)
      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ API endpoint tidak ditemukan. Silakan coba lagi."),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('JSON parsing error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: Invalid response format')),
        );
        setState(() => isLoading = false);
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleLoginSuccess(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Login failed: ${data['message'] ?? response.statusCode}')),
        );
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleLoginSuccess(dynamic responseBody) async {
    final data =
        responseBody is String ? jsonDecode(responseBody) : responseBody;

    // ✅ Fix kondisi deteksi sukses login
    if (data['success'] == true && data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role'] ?? '');

      // Save user data if available
      if (data['user'] != null) {
        await prefs.setString('user_id', data['user']['uuid'] ?? '');
        await prefs.setString('user_name', data['user']['name'] ?? '');
        await prefs.setString('user_email', data['user']['email'] ?? '');
      }

      // Save company data if available (for HRD role)
      if (data['company'] != null) {
        await prefs.setString('company_id', data['company']['uuid'] ?? '');
        await prefs.setString('company_name', data['company']['name'] ?? '');
        await prefs.setString(
            'company_address', data['company']['address'] ?? '');
        print("✅ Company data saved: ${data['company']['name']}");
      } else {
        print("⚠️ No company data in response");
        print("📋 Response data keys: ${data.keys.toList()}");

        // Workaround: Fetch company data from API if not in login response
        if (data['role'] == 'HRD') {
          print("🔄 Fetching company data from API...");
          try {
            final userService = UserService();
            final company = await userService.getMyCompany();

            if (company != null) {
              await prefs.setString('company_id', company.uuid);
              await prefs.setString('company_name', company.name);
              await prefs.setString('company_address', company.address);
              print("✅ Company data fetched and saved: ${company.name}");
            } else {
              print("❌ Could not fetch company data from API");
            }
          } catch (e) {
            print("❌ Error fetching company data: $e");
          }
        }
      }

      print("✅ Login success - role: ${data['role']}");

      // Navigation based on role
      if (data['role'] == 'HRD') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Hrddashboard()),
        );
      } else if (data['role'] == 'SOCIETY') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SocietyDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown role: ${data['role']}')),
        );
      }
    } else {
      print("❌ Login failed condition - data: $data");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0D1B52);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "KerjaQ",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: themeColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Find your opportunity.\nGrow your future.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email_outlined, color: themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline, color: themeColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: themeColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign In",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don’t have an account? ",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OptionPage()),
                    );
                  },
                  child: Text(
                    "Register now",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
