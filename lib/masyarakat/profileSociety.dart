import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../services/profile_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/portfolio_service.dart';

class ProfileSocietyPage extends StatefulWidget {
  const ProfileSocietyPage({super.key});

  @override
  State<ProfileSocietyPage> createState() => _ProfileSocietyPageState();
}

class _ProfileSocietyPageState extends State<ProfileSocietyPage> {
  List<dynamic> portfolios = [];
  bool isLoadingPortfolio = true;
  String? societyUUID =
      "85688570-0184-4054-ba66-675ca36aeb19"; // TODO: Make this dynamic from login

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController =
      TextEditingController(text: "12345678");

  final TextEditingController skillController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  
  // Profile image
  File? profileImage;

  File? portfolioFile;
  String? portfolioFileName;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadPortfolioData(); // Load portfolio data when the page initializes
  }

  // 🔹 Ambil data profile dari local storage
  // Ganti foto profil (tanpa backend)
  Future<void> changeProfilePicture() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.first.path != null) {
      setState(() {
        profileImage = File(result.files.first.path!);
      });

      // Simpan path ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', result.files.first.path!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Foto profil berhasil diperbarui!')),
      );
    }
  }

  Future<void> _loadProfileData() async {
    final profileData = await ProfileService.loadProfile();
    if (mounted) {
      setState(() {
        nameController.text = profileData['name'] ?? '';
        emailController.text = profileData['email'] ?? '';
        
        // Load profile image if exists
        if (profileData['profileImagePath'] != null) {
          profileImage = File(profileData['profileImagePath']!);
        }
      });
    }
  }

  // 🔹 Ambil portfolio dari API berdasarkan UUID
  Future<void> _loadPortfolioData() async {
    if (societyUUID == null) {
      print('⚠️ Society UUID is null');
      return;
    }

    setState(() => isLoadingPortfolio = true);

    try {
      final portfoliosData =
          await PortfolioService().getPortfoliosByUUID(societyUUID!);
      if (mounted) {
        setState(() {
          portfolios = portfoliosData;
        });
      }
    } catch (e) {
      print('❌ Gagal memuat portfolio: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingPortfolio = false);
      }
    }
  }

  // 🔹 Upload file portfolio
  Future<void> pickPortfolioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'rar', 'doc', 'docx'],
    );

    if (result != null && result.files.first.path != null) {
      setState(() {
        portfolioFile = File(result.files.first.path!);
        portfolioFileName = result.files.first.name;
      });
    }
  }

  // 🔹 Kirim portfolio baru ke server
  Future<void> uploadPortfolio() async {
    if (skillController.text.isEmpty ||
        descController.text.isEmpty ||
        portfolioFile == null ||
        societyUUID == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field dan pilih file!')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏳ Mengunggah portfolio...')),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('❌ Token tidak ditemukan, silakan login ulang')),
        );
        return;
      }

      bool success = await PortfolioService.createPortfolio(
        skill: skillController.text,
        description: descController.text,
        societyUUID: societyUUID!,
        token: token,
        filePath: portfolioFile!.path,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Portfolio berhasil diupload!')),
        );
        skillController.clear();
        descController.clear();
        setState(() {
          portfolioFile = null;
          portfolioFileName = null;
        });
        await _loadPortfolioData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Gagal mengunggah portfolio')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    skillController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile & Portfolio",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPortfolioData,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: changeProfilePicture,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : const AssetImage('assets/KerjaQLogo.png')
                                  as ImageProvider,
                          child: profileImage == null
                              ? const Icon(Icons.camera_alt,
                                  color: Colors.grey, size: 28)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: changeProfilePicture,
                        child: Text(
                          "Change Profile Picture",
                          style: GoogleFonts.poppins(
                            color: Colors.indigo.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text("Your Information",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                buildInput("Full Name", nameController),
                buildInput("Email", emailController),
                const SizedBox(height: 25),
                Text("Upload New Portfolio",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                buildInput("Skill", skillController),
                buildInput("Description", descController),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: pickPortfolioFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.file_present, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            portfolioFileName ?? "Pilih file portfolio...",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Icon(Icons.upload, color: Colors.indigo.shade900),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: uploadPortfolio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                    "Upload Portfolio",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),
                Text("My Portfolios",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (isLoadingPortfolio)
                  const Center(child: CircularProgressIndicator())
                else if (portfolios.isEmpty)
                  Center(
                    child: Text(
                      "Belum ada portfolio yang diupload.",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey.shade600),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: portfolios.length,
                    itemBuilder: (context, index) {
                      final p = portfolios[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['skill'] ?? '-',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Text(p['description'] ?? '',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF7F7F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
