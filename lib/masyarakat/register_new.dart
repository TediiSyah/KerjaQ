import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ukk_tedii/masyarakat/societyDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isObscure = true;
  bool isLoading = false;
  String? gender;

  // ===================== REGISTER FUNCTION =====================
  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() => isLoading = true);

    const baseUrl = "https://learn.smktelkom-mlg.sch.id/jobsheeker/";
    const appKey = "d11869cbb24234949e1d47e131adbd7c6fc6d6b2";

    final registerData = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "date_of_birth": dobController.text.trim(),
      "address": addressController.text.trim(),
      "gender": gender,
      "role": "SOCIETY",
    };

    // Try multiple base URL and endpoint combinations for registration
    final baseUrls = [
      "https://learn.smktelkom-mlg.sch.id/jobsheeker/",
    ];

    final endpoints = ['societies', 'auth', 'register'];

    http.Response? response;

    for (final baseUrl in baseUrls) {
      for (final endpoint in endpoints) {
        try {
          debugPrint("Trying registration: ${baseUrl}$endpoint");
          response = await http
              .post(
                Uri.parse("${baseUrl}$endpoint"),
                headers: {
                  "Content-Type": "application/json",
                  "APP-KEY": appKey,
                },
                body: jsonEncode(registerData),
              )
              .timeout(const Duration(seconds: 10));

          debugPrint("REGISTER STATUS: ${response.statusCode}");
          debugPrint("REGISTER BODY: ${response.body}");

          if (response.statusCode != 404 && response.statusCode != 500) {
            debugPrint("✅ Found working registration API: ${baseUrl}$endpoint");
            break;
          } else {
            debugPrint(
                "❌ ${response.statusCode} on registration: ${baseUrl}$endpoint");
          }
        } catch (e) {
          debugPrint("❌ Error on registration ${baseUrl}$endpoint: $e");
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
              "❌ Tidak dapat terhubung ke server registration. Periksa koneksi atau coba lagi nanti."),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    debugPrint("REGISTER STATUS: ${response.statusCode}");
    debugPrint("REGISTER BODY: ${response.body}");

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

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error parsing response: ${response.body}"),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // 4️⃣ Cek email/username/phone duplikat
    String messageStr = "";
    if (decoded["message"] is String) {
      messageStr = decoded["message"];
    } else if (decoded["message"] is Map) {
      messageStr = decoded["message"]["error"]?.toString() ??
          decoded["message"].toString();
    } else {
      messageStr = decoded["message"]?.toString() ?? "";
    }

    if ((response.statusCode == 409) ||
        messageStr.toLowerCase().contains("already") ||
        messageStr.toLowerCase().contains("exist") ||
        messageStr.toLowerCase().contains("registered")) {
      debugPrint("❌ Email sudah terdaftar, login otomatis dibatalkan");

      // Show popup dialog instead of SnackBar
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Email Sudah Terdaftar"),
            content: Text(messageStr.isNotEmpty
                ? messageStr
                : "Email yang Anda masukkan sudah digunakan. Silakan gunakan email lain."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  setState(() => isLoading = false);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return; // 🔒 STOP login otomatis
    }

    // 5️⃣ Jika sukses → lanjut login otomatis
    if ((response.statusCode == 200 || response.statusCode == 201)) {
      final loginResponse = await http.post(
        Uri.parse("${baseUrl}auth"),
        headers: {
          "Content-Type": "application/json",
          "APP-KEY": appKey,
        },
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      debugPrint("LOGIN STATUS: ${loginResponse.statusCode}");
      debugPrint("LOGIN BODY: ${loginResponse.body}");

      dynamic loginData;
      try {
        loginData = jsonDecode(loginResponse.body);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("❌ Error parsing login response: ${loginResponse.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      if ((loginResponse.statusCode == 200 ||
              loginResponse.statusCode == 201) &&
          loginData["token"] != null &&
          loginData["role"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", loginData["token"]);
        await prefs.setString("role", loginData["role"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Register & Login Success!")),
        );

        // Since this is society registration, always go to society dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SocietyDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "⚠️ Login gagal: ${loginData['message'] ?? 'Unknown error'}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decoded["message"] ?? "❌ Register failed."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ===================== UI =====================
  Widget _circleDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B52).withOpacity(0.1),
            const Color(0xFF0D1B52).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF0D1B52).withOpacity(0.3),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _circleDecoration(120)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    Text(
                      "Register as Society",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D1B52),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Fill your details or continue with social media",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: nameController,
                      label: "Full Name",
                      hint: "John Doe",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: emailController,
                      label: "Email",
                      hint: "john@example.com",
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: passwordController,
                      label: "Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      obscure: _isObscure,
                      suffix: IconButton(
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: phoneController,
                      label: "Phone Number",
                      hint: "08123456789",
                      icon: Icons.phone_outlined,
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: dobController,
                      label: "Date of Birth",
                      hint: "2010-10-03",
                      icon: Icons.calendar_today_outlined,
                      inputType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: addressController,
                      label: "Address",
                      hint: "Jl. Contoh No. 123, Jakarta",
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildGenderSelector(),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B52),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: isLoading ? null : _register,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                "Register",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label" : null,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0D1B52), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            value: "MALE",
            groupValue: gender,
            onChanged: (val) => setState(() => gender = val),
            title: const Text("Male"),
            activeColor: const Color(0xFF0D1B52),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            value: "FEMALE",
            groupValue: gender,
            onChanged: (val) => setState(() => gender = val),
            title: const Text("Female"),
            activeColor: const Color(0xFF0D1B52),
          ),
        ),
      ],
    );
  }
}
