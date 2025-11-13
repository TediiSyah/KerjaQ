import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api/api_service.dart';

class JobDetailPage extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  PlatformFile? selectedFile;
  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      setState(() => selectedFile = result.files.first);
    }
  }

  Future<void> _applyJob() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final api = ApiService();
      final response = await api.applyToPosition(widget.job['uuid'].toString());

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lamaran berhasil dikirim!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? 'Gagal apply')),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Terjadi kesalahan server.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Upload CV dan Portofolio",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedFile != null)
                Text("File terpilih: ${selectedFile!.name}"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text("Pilih File"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _applyJob();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text("Kirim Lamaran"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(title: Text(job['position_name'] ?? 'Detail Pekerjaan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              job['position_name'] ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              job['description'] ?? '-',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showUploadDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade900,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Apply Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
