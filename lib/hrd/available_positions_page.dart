import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailablePositionsPage extends StatefulWidget {
  const AvailablePositionsPage({super.key});

  @override
  State<AvailablePositionsPage> createState() => _AvailablePositionsPageState();
}

class _AvailablePositionsPageState extends State<AvailablePositionsPage> {
  List positions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchPositions() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('base_url') ?? 'http://10.0.2.2:8000';
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/available-positions/active'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => positions = data['data']);
        } else {
          debugPrint('⚠️ API error: ${data['message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${data['message']}')),
            );
          }
        }
      } else {
        debugPrint('❌ HTTP error: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load positions')),
          );
        }
      }
    } catch (e) {
      debugPrint('🔥 Fetch error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> addOrEditPosition({Map<String, dynamic>? position}) async {
    final nameController =
        TextEditingController(text: position?['position_name'] ?? '');
    final capacityController =
        TextEditingController(text: position?['capacity']?.toString() ?? '');
    final descController =
        TextEditingController(text: position?['description'] ?? '');
    DateTime? startDate = position?['submission_start_date'] != null
        ? DateTime.parse(position!['submission_start_date'])
        : null;
    DateTime? endDate = position?['submission_end_date'] != null
        ? DateTime.parse(position!['submission_end_date'])
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            position == null ? 'Tambah Posisi' : 'Edit Posisi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Posisi'),
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Kapasitas'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && mounted) {
                      setState(() => startDate = picked);
                    }
                  },
                  child: Text(startDate == null
                      ? 'Pilih Tanggal Mulai'
                      : 'Mulai: ${startDate!.toLocal()}'.split(' ')[0]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && mounted) {
                      setState(() => endDate = picked);
                    }
                  },
                  child: Text(endDate == null
                      ? 'Pilih Tanggal Selesai'
                      : 'Selesai: ${endDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    capacityController.text.isEmpty ||
                    descController.text.isEmpty ||
                    startDate == null ||
                    endDate == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Harap isi semua data terlebih dahulu')),
                    );
                  }
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final baseUrl =
                    prefs.getString('base_url') ?? 'http://10.0.2.2:8000';
                final token = prefs.getString('token');

                final url = position == null
                    ? '$baseUrl/api/available-positions'
                    : '$baseUrl/api/available-positions/${position['uuid']}';

                final method = position == null ? 'POST' : 'PUT';

                try {
                  final body = jsonEncode({
                    "position_name": nameController.text,
                    "capacity": int.parse(capacityController.text),
                    "description": descController.text,
                    "submission_start_date": startDate!.toIso8601String(),
                    "submission_end_date": endDate!.toIso8601String(),
                  });

                  final response = await http.Request(method, Uri.parse(url))
                    ..headers.addAll({
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    })
                    ..body = body;

                  final streamedResponse = await response.send();
                  final responseBody =
                      await streamedResponse.stream.bytesToString();

                  if (mounted) {
                    if (streamedResponse.statusCode == 200 ||
                        streamedResponse.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(position == null
                                ? 'Posisi berhasil ditambahkan!'
                                : 'Posisi berhasil diperbarui!')),
                      );
                      fetchPositions();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal: $responseBody',
                                style: const TextStyle(color: Colors.red))),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e',
                              style: const TextStyle(color: Colors.red))),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Check if a position has expired
  bool isPositionExpired(Map<String, dynamic> position) {
    try {
      final endDate = DateTime.parse(position['submission_end_date']);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return false;
    }
  }

  // Build the status button based on position status
  Widget _buildPositionStatusButton(Map<String, dynamic> position) {
    final isExpired = isPositionExpired(position);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isExpired ? 'Kadaluarsa' : 'Aktif',
        style: GoogleFonts.poppins(
          color: isExpired ? Colors.red.shade800 : Colors.green.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Lowongan',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.indigo.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditPosition(),
        backgroundColor: Colors.indigo.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : positions.isEmpty
              ? Center(
                  child: Text('Belum ada lowongan aktif',
                      style: GoogleFonts.poppins()),
                )
              : ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (context, index) {
                    final pos = positions[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(pos['position_name'] ?? '-',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pos['description'] ?? '-'),
                            const SizedBox(height: 4),
                            Text(
                              'Kuota: ${pos['capacity'] ?? '0'} orang',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              'Periode: ${DateTime.parse(pos['submission_start_date']).toLocal().toString().split(' ')[0]} - ${DateTime.parse(pos['submission_end_date']).toLocal().toString().split(' ')[0]}',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: _buildPositionStatusButton(pos),
                      ),
                    );
                  },
                ),
    );
  }
}
