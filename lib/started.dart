import 'package:flutter/material.dart';
import 'package:ukk_tedii/loginPage.dart';
import 'package:ukk_tedii/masyarakat/register_new.dart';
import 'package:ukk_tedii/option.dart';

class Started extends StatelessWidget {
  const Started({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgStart.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/lineStart.png',
                width: 500,
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.only(right: 250),
                child: Image.asset(
                  'assets/KerjaQLogo.png',
                  width: 90,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Job discovery made smart.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Customize your search to discover job openings that truly align with your career goals.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 350, // Set the width of the button
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to LoginPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(4, 38, 102, 1.0),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                        fontSize: 18, color: Color.fromRGBO(4, 38, 102, 1.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
