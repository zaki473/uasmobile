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
    // Pastikan data siswa terbaru diambil saat halaman dibuka
    Future.microtask(() => 
      Provider.of<StudentProvider>(context, listen: false).fetchStudents()
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background soft
      appBar: AppBar(
        title: const Text(
          'Kelola Data Siswa',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.person_add),
        label: const Text("Tambah Siswa"),
      ),
      body: studentProv.students.isEmpty
          ? const Center(child: Text("Belum ada data siswa"))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: studentProv.students.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = studentProv.students[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      child: Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('NIS: ${s.nis}', style: TextStyle(color: Colors.grey[600])),
                        Text('${s.kelas} • ${s.jurusan}', style: const TextStyle(color: Colors.indigoAccent, fontSize: 12)),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') _showForm(context, student: s);
                        if (value == 'delete') _confirmDelete(context, studentProv, s.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text('Edit Data')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text('Hapus', style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ),
                );
              }),
    );
  }

  // Konfirmasi Hapus agar tidak terpencet
  void _confirmDelete(BuildContext context, StudentProvider prov, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Siswa?"),
        content: const Text("Data siswa dan nilai yang terkait mungkin akan hilang."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              prov.deleteStudent(id);
              Navigator.pop(ctx);
            }, 
            child: const Text("Hapus")
          ),
        ],
      ),
    );
  }

  // FORM INPUT / EDIT (Styled)
  void _showForm(BuildContext context, {Student? student}) {
    final bool isEditing = student != null;
    
    // Controller
    final nisC = TextEditingController(text: student?.nis);
    final nameC = TextEditingController(text: student?.name);
    final kelasC = TextEditingController(text: student?.kelas);
    final jurusanC = TextEditingController(text: student?.jurusan);
    
    // Tambahan untuk Registrasi Akun (Hanya muncul saat Tambah Baru)
    final emailC = TextEditingController(); 
    final passC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Data Siswa' : 'Registrasi Siswa Baru',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 20),

            // --- FORM FIELDS ---
            _buildTextField(nisC, 'NIS / NISN', Icons.badge),
            const SizedBox(height: 12),
            _buildTextField(nameC, 'Nama Lengkap', Icons.person),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(child: _buildTextField(kelasC, 'Kelas', Icons.class_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(jurusanC, 'Jurusan', Icons.school)),
              ],
            ),
            
            // FIELD KHUSUS REGISTRASI (Hanya muncul jika BUKAN Edit)
            if (!isEditing) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text("Akun Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              _buildTextField(emailC, 'Email Siswa', Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(passC, 'Password', Icons.lock_outline, isObscure: true),
            ],

            const SizedBox(height: 25),

            // --- BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  final studentProv = Provider.of<StudentProvider>(context, listen: false);
                  
                  // LOGIKA PENTING DISINI
                  if (isEditing) {
                    // 1. Jika Edit: Hanya update data text
                    final s = Student(
                      id: student.id, // ID tidak berubah
                      nis: nisC.text,
                      name: nameC.text,
                      kelas: kelasC.text,
                      jurusan: jurusanC.text,
                    );
                    await studentProv.updateStudent(s);
                  } else {
                    // 2. Jika Baru: REGISTER KE AUTH + SIMPAN KE DB
                    // Pastikan Provider Anda punya fungsi registerStudentWithAuth
                    await studentProv.addStudentWithAuth(
                      email: emailC.text,
                      password: passC.text,
                      nis: nisC.text,
                      name: nameC.text,
                      kelas: kelasC.text,
                      jurusan: jurusanC.text,
                    );
                  }
                  
                  if(context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? 'Simpan Perubahan' : 'Daftarkan Siswa'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget styling input (seperti sebelumnya)
  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool isObscure = false, TextInputType inputType = TextInputType.text}
  ) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigoAccent, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}