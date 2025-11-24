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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<StudentProvider>(context, listen: false).fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);

    // 1. Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. Tentukan Warna Dasar
    final bgColor = isDark ? null : const Color(0xFFF5F7FA); // Null = default scaffold dark
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: Text(
          'Kelola Data Siswa',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text("Tambah Siswa"),
      ),
      body: studentProv.students.isEmpty
          ? Center(
              child: Text(
                "Belum ada data siswa",
                style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: studentProv.students.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = studentProv.students[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor, // <-- Warna kartu dinamis
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // Shadow lebih tipis/hilang di dark mode
                        color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isDark ? Border.all(color: Colors.white10) : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      child: Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      s.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: textColor, // <-- Warna nama dinamis
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'NIS: ${s.nis}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${s.kelas} • ${s.jurusan}',
                          style: const TextStyle(
                              color: Colors.indigoAccent, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.grey),
                      // Agar menu popup warnanya sesuai tema
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      onSelected: (value) {
                        if (value == 'edit') _showForm(context, student: s);
                        if (value == 'delete')
                          _confirmDelete(context, studentProv, s.id);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, size: 20, color: textColor),
                            const SizedBox(width: 10),
                            Text('Edit Data', style: TextStyle(color: textColor))
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 10),
                            Text('Hapus', style: TextStyle(color: Colors.red))
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }

  void _confirmDelete(BuildContext context, StudentProvider prov, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // AlertDialog otomatis menyesuaikan warna background di Flutter terbaru
        // tapi kita bisa pastikan judulnya benar
        title: const Text("Hapus Siswa?"),
        content: const Text(
            "Data siswa dan nilai yang terkait mungkin akan hilang."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                prov.deleteStudent(id);
                Navigator.pop(ctx);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // FORM INPUT / EDIT (Styled & Dark Mode Ready)
  void _showForm(BuildContext context, {Student? student}) {
    final bool isEditing = student != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Warna untuk modal sheet
    final sheetBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

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
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: sheetBgColor, // <-- Background Modal Dinamis
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Data Siswa' : 'Registrasi Siswa Baru',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const SizedBox(height: 20),

            // --- FORM FIELDS ---
            _buildTextField(context, nisC, 'NIS / NISN', Icons.badge),
            const SizedBox(height: 12),
            _buildTextField(context, nameC, 'Nama Lengkap', Icons.person),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        context, kelasC, 'Kelas', Icons.class_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildTextField(
                        context, jurusanC, 'Jurusan', Icons.school)),
              ],
            ),

            if (!isEditing) ...[
              const SizedBox(height: 12),
              const Divider(),
              Text("Akun Login",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey)),
              const SizedBox(height: 10),
              _buildTextField(context, emailC, 'Email Siswa', Icons.email_outlined,
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(context, passC, 'Password', Icons.lock_outline,
                  isObscure: true),
            ],

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  final studentProv =
                      Provider.of<StudentProvider>(context, listen: false);

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
                child:
                    Text(isEditing ? 'Simpan Perubahan' : 'Daftarkan Siswa'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller,
      String label, IconData icon,
      {bool isObscure = false, TextInputType inputType = TextInputType.text}) {
    
    // Logic warna input field
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      style: TextStyle(color: textColor), // <-- Warna teks input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: Icon(icon, color: Colors.indigoAccent, size: 20),
        filled: true,
        fillColor: fillColor, // <-- Background input dinamis
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}