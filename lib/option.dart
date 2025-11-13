import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'masyarakat/register_new.dart';
import 'hrd/registerHrd.dart';
import 'loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KerjaQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D1B52),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1B52)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const OptionPage(),
    );
  }
}

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  String? selectedOption;

  Widget buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    bool isSelected = selectedOption == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedOption = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D1B52) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF0D1B52) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0D1B52).withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF0D1B52) : Colors.grey[700],
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : const Color(0xFF0D1B52),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue(BuildContext context) {
    if (selectedOption == "Find A Job") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    } else if (selectedOption == "Find An Employee") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterHrd()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an option first."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                "KerjaQ",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B52),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choose your role to get started.\nFind the perfect job or hire the best talent!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Pilihan Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOptionCard(
                    icon: Icons.work_outline,
                    title: "Find A Job",
                    subtitle: "I want to search and apply for job openings.",
                  ),
                  buildOptionCard(
                    icon: Icons.business_center_outlined,
                    title: "Find An Employee",
                    subtitle: "I want to post and manage job openings.",
                  ),
                ],
              ),

              const Spacer(),

              // Tombol Continue
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _onContinue(context),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sudah punya akun
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF0D1B52),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
