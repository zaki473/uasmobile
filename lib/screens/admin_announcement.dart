import 'package:flutter/material.dart';
import 'package:uasmobile/screens/announcement_list.dart';
import 'package:uasmobile/screens/pengumuman.dart';

class AdminAnnouncement extends StatelessWidget {
  const AdminAnnouncement({super.key});

  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan Ruangguru
  final Color bgGrey = const Color(0xFFF4F7F9);    // Abu muda untuk background body
  final Color textDark = const Color(0xFF2D3E50);  // Warna teks gelap

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Background Body dibuat abu-abu muda
      // Supaya kartu putih di dalamnya terlihat kontras & elegan
      backgroundColor: bgGrey,

      // 2. HEADER YANG LEBIH MODERN (Clean Style)
      appBar: AppBar(
        elevation: 0, // Menghilangkan bayangan kasar default
        backgroundColor: Colors.white, // Ganti biru dengan putih
        centerTitle: true,
        
        // Tombol Back yang lebih estetik
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        
        // Judul dengan font yang lebih profesional
        title: Text(
          "Kelola Pengumuman",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        // Garis pemisah tipis di bawah header
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),

      // 3. BODY LIST (Menggunakan widget AnnouncementList yang sudah kita styling tadi)
      body: const AnnouncementList(showDelete: true),

      // 4. TOMBOL TAMBAH (FAB) YANG LEBIH CANTIK
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: rgPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPengumumanScreen()),
          );
        },
        // Menggunakan label teks agar lebih jelas daripada cuma ikon '+'
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Buat Pengumuman",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}