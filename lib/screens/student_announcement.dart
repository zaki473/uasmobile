// lib/screens/student_announcement.dart
import 'package:flutter/material.dart';
import 'package:uasmobile/screens/announcement_list.dart';

class StudentAnnouncement extends StatelessWidget {
  const StudentAnnouncement({Key? key}) : super(key: key);

  // --- STYLE CONSTANTS ---
  final Color bgGrey = const Color(0xFFF4F7F9);   // Background abu muda
  final Color textDark = const Color(0xFF2D3E50); // Warna teks gelap

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey, // 1. Background Body
      
      // 2. CLEAN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        
        // Tombol Back Custom (Minimalis)
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),

        // Judul Halaman
        title: Text(
          "Pengumuman Sekolah",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        // Garis pemisah tipis di bawah AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),

      // 3. BODY (List Pengumuman)
      // Menggunakan widget list yang sudah distyling, 
      // parameter showDelete: false memastikan siswa tidak bisa hapus data.
      body: const AnnouncementList(showDelete: false),
    );
  }
}