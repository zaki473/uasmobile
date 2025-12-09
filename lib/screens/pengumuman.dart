import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPengumumanScreen extends StatefulWidget {
  const AddPengumumanScreen({Key? key}) : super(key: key);

  @override
  State<AddPengumumanScreen> createState() => _AddPengumumanScreenState();
}

class _AddPengumumanScreenState extends State<AddPengumumanScreen> {
  final TextEditingController titleC = TextEditingController();
  final TextEditingController contentC = TextEditingController();

  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde);
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF4A4A4A);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey, // Background abu-abu muda
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          "Tambah Pengumuman",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text Kecil
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  "Detail Informasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),

              // Form Container (Kartu Putih)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Input Judul
                    _buildTextField(
                      controller: titleC,
                      label: "Judul Pengumuman",
                      icon: Icons.title_rounded,
                    ),

                    const SizedBox(height: 20),

                    // Input Isi (Multiline)
                    _buildTextField(
                      controller: contentC,
                      label: "Isi Pengumuman",
                      icon: Icons.article_rounded,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rgPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Simpan Pengumuman",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // Validasi sederhana (opsional UI only)
                    if (titleC.text.isEmpty || contentC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mohon lengkapi semua data")),
                      );
                      return;
                    }

                    // Logic asli (Simpan ke Firebase)
                    await FirebaseFirestore.instance.collection("pengumuman").add({
                      "title": titleC.text,
                      "content": contentC.text,
                      "timestamp": FieldValue.serverTimestamp(),
                    });

                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Text Field yang Konsisten
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGrey),
        alignLabelWithHint: true, // Agar label di atas saat multiline
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 0, bottom: 0),
          child: Icon(icon, color: rgPrimary),
        ),
        filled: true,
        fillColor: bgGrey.withOpacity(0.5), // Warna isian agak abu sangat muda
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rgPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}