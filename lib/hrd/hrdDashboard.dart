import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ukk_tedii/services/api/position_service.dart';
import 'package:ukk_tedii/services/api/application_service.dart';
import 'package:ukk_tedii/models/application_model.dart';
import 'package:google_fonts/google_fonts.dart';

class Hrddashboard extends StatefulWidget {
  const Hrddashboard({super.key});

  @override
  State<Hrddashboard> createState() => _HrddashboardState();
}

class _HrddashboardState extends State<Hrddashboard>
    with SingleTickerProviderStateMixin {
  final bool isHRD = true;
  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final PositionService _positionService = PositionService();
  final ApplicationService _applicationService = ApplicationService();
  bool _isLoading = false;
  late TabController _tabController;
  List<Application> _applications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _loadPositions();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPositions(),
      _loadApplications(),
    ]);
  }

  Future<void> _loadApplications() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final applications = await _applicationService.getCompanyApplications();
      if (mounted) {
        setState(() {
          _applications = applications;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data lamaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPositions() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final positions = await _positionService.fetchAvailablePositions();
      if (mounted) {
        setState(() {
          jobs = List<Map<String, dynamic>>.from(positions);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data lowongan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> jobs = [
    {
      'title': 'Frontend Development',
      'location': 'West Jakarta, DKI Jakarta',
      'salary': 'Rp 7 - 10jt',
      'employmentType': 'Paruh Waktu',
      'experience': '1 - 3 Thn',
      'education': 'S1',
      'category': 'UI/UX Design',
      'contactName': 'Brian Imanuel',
      'contactTitle': 'HRD PT Antariksa Nusantara Indonesia Group',
      'deadline': 0,
      'isOpen': false,
    },
    {
      'title': 'Backend Development',
      'location': 'West Jakarta, DKI Jakarta',
      'salary': 'Rp 7 - 10jt',
      'employmentType': 'Paruh Waktu',
      'experience': '1 - 3 Thn',
      'education': 'S1',
      'category': 'Digital Marketing',
      'contactName': 'Brian Imanuel',
      'contactTitle': 'HRD PT Antariksa Nusantara Indonesia Group',
      'deadline': 35,
      'isOpen': true,
    },
  ];

  // Enhanced edit functionality - Step 1: Select job to edit
  void _showJobSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Pilih untuk Diedit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: jobs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada lowongan yang tersedia untuk diedit.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.indigo.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          job['title'] ?? job['position_name'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          job['location'] ?? 'Location not specified',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.indigo.shade900,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showJobFieldSelectorDialog(job);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  // Enhanced edit functionality - Step 2: Select field to edit
  void _showJobFieldSelectorDialog(Map<String, dynamic> job) {
    final fields = [
      {'name': 'Judul Lowongan', 'key': 'title', 'icon': Icons.work_outline},
      {'name': 'Lokasi', 'key': 'location', 'icon': Icons.location_on_outlined},
      {'name': 'Gaji', 'key': 'salary', 'icon': Icons.attach_money},
      {
        'name': 'Nama Kontak HRD',
        'key': 'contactName',
        'icon': Icons.person_outline
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Edit: ${job['title'] ?? job['position_name'] ?? 'Job'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih bagian yang ingin diedit:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...fields
                    .map((field) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: ListTile(
                            leading: Icon(
                              field['icon'] as IconData,
                              color: Colors.indigo.shade900,
                            ),
                            title: Text(
                              field['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              job[field['key'] as String]?.toString() ??
                                  'Tidak ada data',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showFieldEditDialog(job, field['key'] as String,
                                  field['name'] as String);
                            },
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced edit functionality - Step 3: Edit specific field
  void _showFieldEditDialog(
      Map<String, dynamic> job, String fieldKey, String fieldName) {
    final controller =
        TextEditingController(text: job[fieldKey]?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                fieldKey == 'title'
                    ? Icons.work_outline
                    : fieldKey == 'location'
                        ? Icons.location_on_outlined
                        : fieldKey == 'salary'
                            ? Icons.attach_money
                            : Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit $fieldName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: fieldName,
                    hintText: 'Masukkan $fieldName baru',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      fieldKey == 'title'
                          ? Icons.work_outline
                          : fieldKey == 'location'
                              ? Icons.location_on_outlined
                              : fieldKey == 'salary'
                                  ? Icons.attach_money
                                  : Icons.person_outline,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.indigo.shade900,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data saat ini: ${job[fieldKey]?.toString() ?? 'Tidak ada data'}',
                          style: TextStyle(
                            color: Colors.indigo.shade900,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          // Update field menggunakan dynamic key
                          job[fieldKey] = controller.text;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$fieldName berhasil diupdate!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.indigo.shade900,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  // Add new job functionality
  Future<void> _showEditDialog([Map<String, dynamic>? jobToEdit]) async {
    final isEditing = jobToEdit != null;

    // Helper function to safely get string value from map
    String getString(Map<String, dynamic> map, String key,
        [String defaultValue = '']) {
      return map[key]?.toString() ?? defaultValue;
    }

    // Initialize controllers with null-safe values
    final titleController = TextEditingController(
        text: isEditing
            ? getString(
                jobToEdit, 'position_name', getString(jobToEdit, 'title', ''))
            : '');

    final descriptionController = TextEditingController(
        text: isEditing ? getString(jobToEdit, 'description') : '');

    final capacityController = TextEditingController(
        text: isEditing ? getString(jobToEdit, 'capacity', '1') : '1');

    // Format dates if they exist
    String formatDate(dynamic dateValue) {
      if (dateValue == null) return '';
      final dateString = dateValue.toString();
      if (dateString.isEmpty) return '';

      try {
        final date = DateTime.tryParse(dateString);
        if (date == null) return '';
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (e) {
        debugPrint('Error formatting date: $e');
        return '';
      }
    }

    final startDateController = TextEditingController(
        text: isEditing ? formatDate(jobToEdit['submission_start_date']) : '');

    final endDateController = TextEditingController(
        text: isEditing ? formatDate(jobToEdit['submission_end_date']) : '');

    // Initialize date variables
    DateTime? startDate;
    DateTime? endDate;

    // Parse dates if they exist
    if (isEditing) {
      try {
        final startDateStr = jobToEdit['submission_start_date']?.toString();
        final endDateStr = jobToEdit['submission_end_date']?.toString();

        if (startDateStr != null && startDateStr.isNotEmpty) {
          startDate = DateTime.tryParse(startDateStr);
        }
        if (endDateStr != null && endDateStr.isNotEmpty) {
          endDate = DateTime.tryParse(endDateStr);
        }
      } catch (e) {
        debugPrint('Error parsing dates: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Update Lowongan' : 'Tambah Lowongan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Nama Posisi *',
                    hintText: 'Contoh: Frontend Developer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Pekerjaan *',
                    hintText: 'Deskripsikan tanggung jawab dan kualifikasi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kuota *',
                    hintText: 'Contoh: 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.people_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Mulai Pendaftaran *',
                    hintText: 'Pilih tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      startDate =
                          DateTime(date.year, date.month, date.day, 12, 0, 0);
                      startDateController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Akhir Pendaftaran *',
                    hintText: 'Pilih tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.event),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      endDate =
                          DateTime(date.year, date.month, date.day, 12, 0, 0);
                      endDateController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          capacityController.text.isEmpty ||
                          startDateController.text.isEmpty ||
                          endDateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field harus diisi!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      try {
                        Map<String, dynamic> result;

                        if (isEditing) {
                          result = await _positionService.editPosition(
                            positionId: jobToEdit['id'],
                            positionName: titleController.text,
                            capacity:
                                int.tryParse(capacityController.text) ?? 1,
                            description: descriptionController.text,
                            submissionStartDate: startDateController.text,
                            submissionEndDate: endDateController.text,
                          );
                        } else {
                          try {
                            result = await _positionService.createPosition(
                              positionName: titleController.text,
                              capacity:
                                  int.tryParse(capacityController.text) ?? 1,
                              description: descriptionController.text,
                              submissionStartDate: startDateController.text,
                              submissionEndDate: endDateController.text,
                            );
                          } catch (e) {
                            print('Error calling createPosition: $e');
                            rethrow;
                          }
                        }

                        setState(() => _isLoading = false);
                        navigator.pop();

                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  result['success']
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    result['message'] ??
                                        (isEditing
                                            ? 'Gagal memperbarui lowongan'
                                            : 'Gagal menambahkan lowongan'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor:
                                result['success'] ? Colors.green : Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );

                        // Refresh positions after successful operation
                        if (result['success'] == true) {
                          _loadPositions();
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Terjadi kesalahan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      isEditing ? 'Update' : 'Simpan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    // Safely get values with defaults
    final bool isOpen = job['isOpen'] ?? true;
    final int deadline = job['deadline'] is int ? job['deadline'] : 0;

    // Helper function to safely get string with fallback
    String getString(String key, [String defaultValue = '']) {
      return job[key]?.toString() ?? defaultValue;
    }

    // Get all values with proper null safety
    final String title =
        getString('position_name', getString('title', 'No Title'));
    final String salary = getString('salary', 'Salary not specified');
    final String location = getString('location', 'Location not specified');
    final String employmentType = getString('employmentType', 'Full-time');
    final String experience =
        getString('experience', 'Experience not specified');
    final String education = getString('education', 'Education not specified');
    final String category = getString('category', 'Other');
    final String contactName = getString('contactName', 'HRD');
    final String contactTitle = getString('contactTitle', 'HRD Contact');

    return GestureDetector(
      onTap: () => _showJobFieldSelectorDialog(job), // Tap to edit specific job
      onLongPress: () => _deleteJob(job), // Long press to delete
      child: Card(
        margin: const EdgeInsets.only(top: 12),
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Salary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    salary,
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _smallChip(employmentType),
                  _smallChip(experience),
                  _smallChip(education),
                  _smallChip(category),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: const AssetImage('assets/lamar1.jpeg'),
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Failed to load job avatar: $exception');
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          contactTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Deadline: $deadline Days',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOpen ? Colors.black54 : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          border: Border.all(
                              color: isOpen ? Colors.green : Colors.redAccent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'Open Requirement' : 'Close Requirement',
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green.shade700
                                : Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      labelStyle: const TextStyle(fontSize: 12),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/company.jpeg',
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/preloved.png'),
              onBackgroundImageError: (exception, stackTrace) {
                // Use fallback color if asset fails
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'PT Antariksa Nusantara\nIndonesia Group',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return const Text(
      'PT Antariksa Nusantara Indonesia Group is a pioneer in space technology innovation in Indonesia, established in 2017 with the mission of accelerating the development of the national technology ecosystem. '
      'We focus on developing cutting-edge technology solutions that support space research, industry, and the wider community. '
      'Committed to advancing Indonesia\'s technological sovereignty, we design data-driven applications and systems that deliver tangible impact across various sectors, from aerospace to digital solutions for modern.',
      style: TextStyle(fontSize: 13, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildTags() {
    final tags = ['Paruh Waktu', '1 - 3 Thn', 'S1', 'Digital Marketing'];
    return Wrap(
      spacing: 8,
      children: tags
          .map((tag) => Chip(
                label: Text(tag),
                side: const BorderSide(color: Colors.grey),
                backgroundColor: Colors.white,
              ))
          .toList(),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Open Requirement',
              style: TextStyle(color: Colors.green, fontSize: 12)),
        ),
        Row(
          children: const [
            Icon(Icons.star, color: Colors.orange, size: 18),
            SizedBox(width: 4),
            Text('4.5 (126 reviews)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  void _deleteJob(Map<String, dynamic> job) {
    // Safely get job title with fallback
    final String jobTitle = job['title']?.toString() ??
        job['position_name']?.toString() ??
        'lowongan ini';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Hapus Lowongan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever_rounded,
                  size: 48,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin menghapus lowongan "$jobTitle"?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        jobs.remove(job);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Lowongan berhasil dihapus!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.indigo.shade900,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  Widget _buildApplicationItem(Application application) {
    bool isUnread = application.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to application detail
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor:
                      isUnread ? Colors.blue.shade100 : Colors.grey.shade200,
                  child: Text(
                    application.applicantName?.isNotEmpty == true
                        ? application.applicantName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: isUnread
                          ? Colors.blue.shade800
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with name and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            application.applicantName ?? 'Pelamar',
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            application.appliedAt != null
                                ? DateFormat('HH:mm')
                                    .format(application.appliedAt!)
                                : '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Position
                      Text(
                        application.positionName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(application.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(application.status),
                          style: TextStyle(
                            color: _getStatusColor(application.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Review';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('HRD Dashboard', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
          ),
          backgroundColor: Colors.indigo.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.work), text: 'Lowongan'),
              Tab(icon: Icon(Icons.email), text: 'Lamaran Masuk'),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPositionsTab(),
              _buildApplicationsTab(),
            ],
          ),
        ),
      ),
    );
  }

  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Today',
    'This Week',
    'This Month'
  ];
  TextEditingController _searchController = TextEditingController();

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (month < 1) month += 12;
    return monthNames[(month - 1) % 12];
  }

  Future<void> _showFilterDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Filter by Date',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0C1B73),
                fontWeight: FontWeight.w600,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _filterOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: GoogleFonts.poppins(fontSize: 14)),
                value: option,
                groupValue: _selectedFilter,
                activeColor: const Color(0xFF0C1B73),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Application> get filteredApplications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    var filtered = _applications.where((app) {
      if (_selectedFilter == 'All') return true;
      if (app.appliedAt == null) return false;

      final appDate = DateTime(
        app.appliedAt!.year,
        app.appliedAt!.month,
        app.appliedAt!.day,
      );

      if (_selectedFilter == 'Today') {
        return appDate.difference(today).inDays == 0;
      } else if (_selectedFilter == 'This Week') {
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return appDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            appDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      } else if (_selectedFilter == 'This Month') {
        return appDate.month == now.month && appDate.year == now.year;
      }
      return false;
    }).toList();

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        return (app.applicantName?.toLowerCase().contains(searchQuery) ??
                false) ||
            (app.positionName?.toLowerCase().contains(searchQuery) ?? false) ||
            (app.applicantPhone?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  Widget _buildApplicationsTab() {
    final filteredApps = filteredApplications;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFF0C1B73),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text("Lamaran Masuk",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                      )),
                  Text(
                    "${_applications.length} lamaran, ${_applications.where((a) => a.status.toLowerCase() == 'pending').length} Belum dibaca",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search & Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: (_) => setState(() {}),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Cari lamaran...",
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 20, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showFilterDialog,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _selectedFilter == 'All'
                                ? Icons.filter_list
                                : Icons.filter_alt,
                            color: const Color(0xFF0C1B73),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Applications List
                  Expanded(
                    child: filteredApps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada lamaran yang ditemukan',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty ||
                                    _selectedFilter != 'All')
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedFilter = 'All';
                                      });
                                    },
                                    child: Text(
                                      'Hapus filter',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0C1B73),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredApps.length,
                            itemBuilder: (context, index) {
                              return _buildApplicationItem(filteredApps[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsTab() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildCompanyInfo(),
            const SizedBox(height: 16),
            _buildTags(),
            const SizedBox(height: 12),
            _buildRating(),
            const SizedBox(height: 16),
            ...jobs.map((job) => _buildJobCard(job)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isHRD
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade900.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showJobSelectorDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Edit Section',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade900.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Add Section',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
