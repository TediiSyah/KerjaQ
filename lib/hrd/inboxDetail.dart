import 'package:flutter/material.dart';

class InboxDetail extends StatelessWidget {
  final String name;
  final String position;
  final String email;
  final String image;

  const InboxDetail({
    Key? key,
    required this.name,
    required this.position,
    required this.email,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Message"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage(image), radius: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        "to : ceo@antariksa.co.id",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Job Application - $position",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                "Dear CEO of PT Antariksa Nusantara Indonesia Group,\n\n"
                "Let me introduce myself. My name is John Lennon, and I am very interested in applying for the Graphic Designer position at PT Antariksa Nusantara Indonesia Group as advertised on LinkedIn. With a Bachelor's degree in Information Technology and expertise in web development, I am confident I can contribute to developing innovative technology solutions.\n",
                style: TextStyle(height: 1.6),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/sample_image.jpg'),
              ),
              const SizedBox(height: 16),
              const Text(
                "Thank you for your time and attention. I look forward to hearing from you.\n\n"
                "Sincerely,\nJohn Lennon\nlennon2112@gmail.com\n+4419708072822\n\nAttachments: CV, Portfolio, Resume",
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.reply),
                    label: const Text("Reply"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C1B73),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.forward, color: Color(0xFF0C1B73)),
                    label: const Text("Forward",
                        style: TextStyle(color: Color(0xFF0C1B73))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0C1B73)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
