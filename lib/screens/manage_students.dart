import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  // --- STYLE CONSTANTS ---
  final Color rgPrimary = const Color(0xFF3ecfde); // Cyan
  final Color bgGrey = const Color(0xFFF4F7F9);
  final Color textDark = const Color(0xFF2D3E50);
  final Color textGrey = const Color(0xFF9B9B9B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<StudentProvider>(context, listen: false).fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: bgGrey, // Background Abu Muda

      // --- HEADER ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          'Kelola Data Siswa',
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

      // --- FAB (TOMBOL TAMBAH) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: rgPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text("Tambah Siswa", style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      // --- BODY ---
      body: studentProv.students.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada data siswa",
                    style: TextStyle(color: textGrey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: studentProv.students.length,
              itemBuilder: (context, index) {
                final s = studentProv.students[index];
                return _buildStudentCard(s, studentProv);
              },
            ),
    );
  }

  // --- WIDGET CARD SISWA ---
  Widget _buildStudentCard(Student s, StudentProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Avatar Inisial
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: rgPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
              style: TextStyle(color: rgPrimary, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        // Info Siswa
        title: Text(
          s.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            // Chip Kelas
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.kelas,
                    style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text("•   ${s.jurusan}", style: TextStyle(color: textGrey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text("NIS: ${s.nis}", style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
        // Menu Titik Tiga
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert_rounded, color: textGrey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit') _showForm(context, student: s);
            if (value == 'delete') _confirmDelete(context, prov, s.id);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_rounded, size: 20, color: textDark),
                const SizedBox(width: 12),
                Text('Edit Data', style: TextStyle(color: textDark))
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Text('Hapus', style: TextStyle(color: Colors.red))
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG KONFIRMASI HAPUS
  void _confirmDelete(BuildContext context, StudentProvider prov, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Siswa?"),
        content: const Text("Data siswa dan nilai yang terkait akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Batal", style: TextStyle(color: textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              prov.deleteStudent(id);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FORM INPUT / EDIT (MODAL SHEET) ---
  void _showForm(BuildContext context, {Student? student}) {
    final bool isEditing = student != null;

    final nisC = TextEditingController(text: student?.nis);
    final nameC = TextEditingController(text: student?.name);
    final kelasC = TextEditingController(text: student?.kelas);
    final jurusanC = TextEditingController(text: student?.jurusan);
    final emailC = TextEditingController();
    final passC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 25,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              isEditing ? 'Edit Data Siswa' : 'Registrasi Siswa Baru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 20),

            _buildTextField(nisC, 'NIS / NISN', Icons.badge_outlined),
            const SizedBox(height: 12),
            _buildTextField(nameC, 'Nama Lengkap', Icons.person_outline),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildTextField(kelasC, 'Kelas (X)', Icons.class_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(jurusanC, 'Jurusan (IPA)', Icons.school_outlined)),
              ],
            ),

            if (!isEditing) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 10),
              Text("Akun Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 10),
              _buildTextField(emailC, 'Email Siswa', Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(passC, 'Password', Icons.lock_outline, isObscure: true),
            ],

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rgPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final studentProv = Provider.of<StudentProvider>(context, listen: false);

                  if (isEditing) {
                    final s = Student(
                      id: student.id,
                      nis: nisC.text,
                      name: nameC.text,
                      kelas: kelasC.text,
                      jurusan: jurusanC.text,
                    );
                    await studentProv.updateStudent(s);
                  } else {
                    await studentProv.addStudentWithAuth(
                      email: emailC.text,
                      password: passC.text,
                      nis: nisC.text,
                      name: nameC.text,
                      kelas: kelasC.text,
                      jurusan: jurusanC.text,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(
                  isEditing ? 'Simpan Perubahan' : 'Daftarkan Siswa',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper Widget Text Field
  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isObscure = false, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      style: TextStyle(color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGrey),
        prefixIcon: Icon(icon, color: rgPrimary, size: 22),
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