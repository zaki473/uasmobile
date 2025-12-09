import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPengumumanScreen extends StatefulWidget {
  final String id;
  final String oldTitle;
  final String oldContent;

  const EditPengumumanScreen({
    Key? key,
    required this.id,
    required this.oldTitle,
    required this.oldContent,
  }) : super(key: key);

  @override
  State<EditPengumumanScreen> createState() => _EditPengumumanScreenState();
}

class _EditPengumumanScreenState extends State<EditPengumumanScreen> {
  late TextEditingController titleC;
  late TextEditingController contentC;

  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan khas Ruangguru
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF4A4A4A);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.oldTitle);
    contentC = TextEditingController(text: widget.oldContent);
  }

  @override
  void dispose() {
    titleC.dispose();
    contentC.dispose();
    super.dispose();
  }

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
          "Edit Pengumuman",
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
              // Header Text
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  "Perbarui Informasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),

              // Form Card
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
                      icon: Icons.edit_note_rounded,
                    ),

                    const SizedBox(height: 20),

                    // Input Isi
                    _buildTextField(
                      controller: contentC,
                      label: "Isi Pengumuman",
                      icon: Icons.notes_rounded,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Simpan Perubahan
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
                    "Simpan Perubahan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // Logic Update ke Firebase (Tidak diubah)
                    await FirebaseFirestore.instance
                        .collection("pengumuman")
                        .doc(widget.id)
                        .update({
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

  // Helper Widget untuk Text Field
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
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: rgPrimary),
        ),
        filled: true,
        fillColor: bgGrey.withOpacity(0.5),
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