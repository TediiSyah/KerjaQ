import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jobDetailPage.dart';
import '../../services/profile_service.dart';
import '../../services/api/position_service.dart';
import 'dart:io';

class SocietyDashboard extends StatefulWidget {
  const SocietyDashboard({super.key});

  @override
  State<SocietyDashboard> createState() => _SocietyDashboardState();
}

class _SocietyDashboardState extends State<SocietyDashboard> {
  // Profile data
  String profileName = "Tedii";
  String profileEmail = "tediisyah@gmail.com";
  String? profileImagePath;

  // Job listings
  List<dynamic> jobList = [];
  bool isLoading = true;
  String errorMessage = '';
  final PositionService _positionService = PositionService();

  // Format date from '2025-11-10' to '10 Nov 2025'
  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Helper method to build tag widgets
  Widget _buildTag(String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadJobListings();
  }

  Future<void> _loadJobListings() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print('🔍 Fetching job listings...');
      final jobs = await _positionService.fetchAvailablePositions();

      if (!mounted) return;

      print('✅ Successfully fetched ${jobs.length} jobs');

      // Filter out any null or invalid job entries
      final validJobs = jobs.where((job) => job != null).toList();

      if (validJobs.isNotEmpty) {
        print('📋 Found ${validJobs.length} valid job listings');
        setState(() {
          jobList = List<dynamic>.from(validJobs);
          isLoading = false;
        });
      } else {
        print('ℹ️ No valid job listings found');
        setState(() {
          jobList = [];
          isLoading = false;
          errorMessage = 'Tidak ada lowongan tersedia saat ini.';
        });
      }
    } catch (e) {
      print('❌ Error in _loadJobListings: $e');

      if (!mounted) return;

      // Handle 401 Unauthorized error
      if (e.toString().contains('401')) {
        print('🔑 Detected 401 - Showing session expired dialog');
        await showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder: (context) => AlertDialog(
            title: const Text('Sesi Berakhir'),
            content:
                const Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Clear any existing data and navigate to login
        if (mounted) {
          // Clear any stored tokens or user data here if needed
          // await YourAuthService.logout();

          // Navigate to login page and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } else {
        // For other errors, show generic error message
        setState(() {
          errorMessage = 'Gagal memuat lowongan. Silakan coba lagi.';
          isLoading = false;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat lowongan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadProfileData() async {
    final profileData = await ProfileService.loadProfile();

    if (mounted) {
      setState(() {
        profileName = profileData['name'] ?? "Tedii";
        profileEmail = profileData['email'] ?? "tediisyah@gmail.com";
        profileImagePath = profileData['profileImagePath'];
      });
    }
  }

  Future<void> _navigateToProfile() async {
    await Navigator.pushNamed(context, '/profileSociety');

    // Refresh profile data when returning from profile page
    if (mounted) {
      _loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi $profileName",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "How Are You Today?",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToProfile,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImagePath != null
                            ? FileImage(File(profileImagePath!))
                                as ImageProvider
                            : NetworkImage('https://i.pravatar.cc/150?img=12')
                                as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔍 Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                "There's an interesting vacancy, you know!!",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Icon(Icons.mic, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                // 📄 Job List
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage,
                                  style: GoogleFonts.poppins(color: Colors.red),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _loadJobListings,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : jobList.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada lowongan tersedia saat ini',
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: jobList.length,
                                itemBuilder: (context, index) {
                                  final job = jobList[index];
                                  // Format tags from the API response
                                  final tags = [
                                    job['job_type']?.toString() ?? '',
                                    job['experience']?.toString() ?? '',
                                    job['education']?.toString() ?? ''
                                  ].where((tag) => tag.isNotEmpty).toList();

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JobDetailPage(
                                            job: job,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade200,
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (job['position_name'] as String?) ??
                                                'No Position Name',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                (job['company']?['name']
                                                        as String?) ??
                                                    'No Company',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                '${job['salary']?.toString() ?? '0'} IDR',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.indigo.shade900,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // 🏷 Tags
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              if (job['job_type'] != null)
                                                _buildTag(job['job_type']),
                                              if (job['experience'] != null)
                                                _buildTag(job['experience']),
                                              if (job['education'] != null)
                                                _buildTag(job['education']),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // 👤 Recruiter & status
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundImage: NetworkImage(
                                                        'https://i.pravatar.cc/150?img=3'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (job['company']?['name']
                                                                as String?) ??
                                                            'Recruiter',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .indigo.shade900,
                                                        ),
                                                      ),
                                                      Text(
                                                        (job['company']
                                                                    ?['sector']
                                                                as String?) ??
                                                            'Company Sector',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Deadline: ${(job['deadline'] as String?) ?? ''}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .green.shade400),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      'Open',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .green.shade600,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                  );
                                },
                              ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
