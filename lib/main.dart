import 'package:flutter/material.dart';
import 'package:ukk_tedii/hrd/hrdDashboard.dart';
import 'package:ukk_tedii/hrd/inbox_page.dart';
import 'package:ukk_tedii/hrd/myCompanyPage.dart';
import 'package:ukk_tedii/intro.dart';
import 'package:ukk_tedii/loginPage.dart';
import 'package:ukk_tedii/masyarakat/societyDashboard.dart';
import 'package:ukk_tedii/masyarakat/profileSociety.dart';
import 'package:ukk_tedii/masyarakat/historyScreen.dart';
import 'package:ukk_tedii/masyarakat/companiesPage.dart';
import 'package:ukk_tedii/debug/session_debug_page.dart';
import 'package:ukk_tedii/option.dart';
import 'package:ukk_tedii/started.dart';
import 'splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KerjaQ App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/intro': (context) => const IntroPage(),
        '/started': (context) => const Started(),
        '/history': (context) => const HistoryScreen(),
        '/profileSociety': (context) => const ProfileSocietyPage(),
        '/hrdDashboard': (context) => const Hrddashboard(),
        '/societyDashboard': (context) => const SocietyDashboard(),
        '/inbox': (context) => const InboxPage(),
        '/companies': (context) => const CompaniesPage(),
        '/myCompany': (context) => const MyCompanyPage(),
        '/debug': (context) => const SessionDebugPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // You can navigate back to splash if needed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          },
          child: const Text('Go to Splash Screen'),
        ),
      ),
    );
  }
}
