import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  bool isLoading = true;
  List<dynamic> applications = [];

  final String baseUrl = 'https://learn.smktelkom-mlg.sch.id/jobsheeker';
  final String appKey =
      'd11869cbb24234949e1d47e131adbd7c6fc6d6b2'; // token indodax

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("🔑 TOKEN HRD: $token");

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token HRD tidak ditemukan. Silakan login ulang.')),
        );
        setState(() => isLoading = false);
        return;
      }

      // ✅ Gunakan endpoint yang benar
      final res = await http.get(
        Uri.parse('$baseUrl/position-applied?page=1&quantity=100'),
        headers: {
          'Accept': 'application/json',
          'APP-KEY': appKey,
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 STATUS CODE: ${res.statusCode}');
      print('📦 RESPONSE BODY: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            applications = body['data'] ?? [];
          });
          print("✅ Total lamaran masuk: ${applications.length}");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(body['message'] ?? 'Gagal mengambil data lamaran')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat data lamaran (${res.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(String uuid, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.patch(
        Uri.parse('$baseUrl/position-applied/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'APP-KEY': appKey,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final result = jsonDecode(res.body);
      if (res.statusCode == 200 && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Lamaran ${status == 'ACCEPTED' ? 'diterima' : 'ditolak'}')),
        );
        fetchApplications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal update status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lamaran Masuk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
              ? const Center(child: Text('Belum ada lamaran masuk'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    final applicant = app['society'] ?? {};
                    final position = app['available_position'] ?? {};

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              position['position_name'] ??
                                  'Posisi Tidak Diketahui',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pelamar: ${applicant['name'] ?? '-'}',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            Text(
                              'Status: ${app['status'] ?? 'PENDING'}',
                              style: GoogleFonts.poppins(
                                color: app['status'] == 'ACCEPTED'
                                    ? Colors.green
                                    : app['status'] == 'REJECTED'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      updateStatus(app['uuid'], 'ACCEPTED'),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Terima'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      updateStatus(app['uuid'], 'REJECTED'),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Tolak'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
