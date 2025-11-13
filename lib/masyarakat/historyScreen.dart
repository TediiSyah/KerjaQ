import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool hasUploaded = false; // default: belum upload file

  // Data dummy file (akan tampil kalau hasUploaded = true)
  final uploadedFile = {
    "name": "APPLICATION_TO_CANCEL.docx",
    "size": "28.50 KB",
    "date": "16/11/2022",
  };

  // ---------------- Upload Now Card ----------------
  Widget _buildUploadNowCard() {
    return Container(
      key: const ValueKey('uploadNowCard'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            "You haven't uploaded any file yet.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  hasUploaded = true; // simulasi upload selesai
                });
              },
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(
                "Upload Now",
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Timeline card ----------------
  Widget _buildInspectionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "File Inspection",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "ESTIMATED TIME OF ANNOUNCEMENT",
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineItem(
                isActive: true,
                color: Colors.amber,
                text: "Have successfully submitted your job application.",
              ),
              _buildTimelineItem(
                isActive: true,
                color: Colors.orangeAccent,
                text: "Application files are being checked.",
              ),
              _buildTimelineItem(
                isActive: false,
                color: Colors.grey,
                text: "Awaiting further updates.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isActive,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 35,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isActive ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Uploaded File Card ----------------
  Widget _buildUploadedFileCard() {
    return Container(
      key: const ValueKey('uploadedFileCard'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name & date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  uploadedFile["name"]!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    uploadedFile["date"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Size + icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    uploadedFile["size"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.remove_red_eye_outlined,
                        color: Colors.indigo),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        hasUploaded = false; // hapus file
                      });
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status + button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.more_horiz, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Pending Document Approval",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "History",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInspectionCard(),

            const SizedBox(height: 25),

            // Use AnimatedSwitcher to prevent overlapping during transitions
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: hasUploaded
                  ? _buildUploadedFileCard()
                  : _buildUploadNowCard(),
            ),
          ],
        ),
      ),
    );
  }
}
