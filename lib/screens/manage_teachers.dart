import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teacher_provider.dart';
import '../models/teacher.dart';

class ManageTeachers extends StatefulWidget {
  const ManageTeachers({super.key});

  @override
  State<ManageTeachers> createState() => _ManageTeachersState();
}

class _ManageTeachersState extends State<ManageTeachers> {
  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF2D3E50);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  void initState() {
    super.initState();
    // Memanggil data saat init (Logic tidak diubah)
    Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TeacherProvider>(context);

    return Scaffold(
      backgroundColor: bgGrey, // Background abu muda
      
      // --- HEADER ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          "Kelola Guru",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      // --- TOMBOL TAMBAH (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: rgPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Tambah Guru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showForm(context),
      ),

      // --- LIST GURU ---
      body: prov.teachers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada data guru", style: TextStyle(color: textGrey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: prov.teachers.length,
              itemBuilder: (_, i) {
                final t = prov.teachers[i];
                return _buildTeacherCard(t, prov);
              },
            ),
    );
  }

  // --- WIDGET CARD GURU ---
  Widget _buildTeacherCard(Teacher t, TeacherProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / Icon
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: rgPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                t.name.isNotEmpty ? t.name[0].toUpperCase() : "?",
                style: TextStyle(
                  color: rgPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Detail Guru
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama
                Text(
                  t.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Subject Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.subject,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Email & Phone
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        t.email,
                        style: TextStyle(fontSize: 12, color: textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              // Edit Button
              InkWell(
                onTap: () => _showForm(context, teacher: t),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 18),
                ),
              ),
              const SizedBox(height: 8),
              // Delete Button
              InkWell(
                onTap: () {
                  // Confirm dialog bisa ditambahkan, tapi sesuai request function tetap
                  prov.deleteTeacher(t.id);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- FORM BOTTOM SHEET ---
  void _showForm(BuildContext context, {Teacher? teacher}) {
    final isEdit = teacher != null;

    final nameC = TextEditingController(text: teacher?.name);
    final subjectC = TextEditingController(text: teacher?.subject);
    final emailC = TextEditingController(text: teacher?.email);
    final phoneC = TextEditingController(text: teacher?.phone);
    final passwordC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparan agar rounded corner terlihat
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Sheet
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? "Edit Data Guru" : "Tambah Guru Baru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField("Nama Lengkap", nameC, Icons.person_outline),
              const SizedBox(height: 12),

              _buildTextField("Mata Pelajaran", subjectC, Icons.book_outlined),
              const SizedBox(height: 12),

              _buildTextField("Email", emailC, Icons.email_outlined, 
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 12),

              _buildTextField("Nomor Telepon", phoneC, Icons.phone_outlined, 
                  inputType: TextInputType.phone),
              const SizedBox(height: 12),

              if (!isEdit)
                _buildTextField("Password Akun", passwordC, Icons.lock_outline, 
                    obscure: true),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rgPrimary, // Pakai Cyan
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    // --- LOGIC VALIDASI & SAVE (TIDAK DIUBAH DARI CODE ASAL) ---
                    final name = nameC.text.trim();
                    final subject = subjectC.text.trim();
                    final email = emailC.text.trim();
                    final phone = phoneC.text.trim();
                    final password = passwordC.text.trim();

                    if (name.isEmpty ||
                        subject.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        (!isEdit && password.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Semua field wajib diisi')),
                      );
                      return;
                    }

                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Format email tidak valid')),
                      );
                      return;
                    }

                    if (!isEdit && password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password minimal 6 karakter'),
                        ),
                      );
                      return;
                    }

                    final prov = Provider.of<TeacherProvider>(
                      context,
                      listen: false,
                    );

                    if (isEdit) {
                      final updated = Teacher(
                        id: teacher.id,
                        name: name,
                        subject: subject,
                        email: email,
                        phone: phone,
                      );
                      await prov.updateTeacher(updated);
                    } else {
                      final error = await prov.addTeacherWithAuth(
                        email: email,
                        password: password,
                        name: name,
                        subject: subject,
                        phone: phone,
                      );

                      if (error != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                        return;
                      }
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    isEdit ? "Simpan Perubahan" : "Tambah Guru",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget Field Styled
  Widget _buildTextField(String label, TextEditingController c, IconData icon, 
      {bool obscure = false, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: inputType,
      style: TextStyle(color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGrey),
        prefixIcon: Icon(icon, color: rgPrimary),
        filled: true,
        fillColor: bgGrey.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rgPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}