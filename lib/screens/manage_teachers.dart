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
  @override
  void initState() {
    super.initState();
    Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Guru")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prov.teachers.length,
        itemBuilder: (_, i) {
          final t = prov.teachers[i];

          return Card(
            child: ListTile(
              title: Text(t.name),
              subtitle: Text("${t.subject} • ${t.email}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showForm(context, teacher: t),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      prov.deleteTeacher(t.id);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Edit Guru" : "Tambah Guru",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _field("Nama Guru", nameC),
              const SizedBox(height: 10),

              _field("Mata Pelajaran", subjectC),
              const SizedBox(height: 10),

              _field("Email", emailC),
              const SizedBox(height: 10),

              _field("Nomor Telepon", phoneC),
              const SizedBox(height: 10),

              if (!isEdit)
                _field("Password Akun Guru", passwordC, obscure: true),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  // Validasi form sebelum submit
                  final name = nameC.text.trim();
                  final subject = subjectC.text.trim();
                  final email = emailC.text.trim();
                  final phone = phoneC.text.trim();
                  final password = passwordC.text.trim();

                  // Cek field kosong
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

                  // Validasi format email
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Format email tidak valid')),
                    );
                    return;
                  }

                  // Validasi panjang password (minimal 6 karakter)
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
                child: Text(isEdit ? "Simpan" : "Tambah"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _field(String label, TextEditingController c, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
