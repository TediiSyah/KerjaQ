import 'package:flutter/material.dart';
import 'started.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/cweSeeker.png',
                width: 350,
                height: 350,
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Job discovery made smart.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Color.fromRGBO(4, 38, 102, 1.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Customize your search to discover job openings that truly align with your career goals.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(4, 38, 102, 1.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 350, // Set the width of the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Started()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(4, 38, 102, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18),
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
