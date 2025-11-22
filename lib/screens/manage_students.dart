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
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Data Siswa')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: studentProv.students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: studentProv.students.length,
              itemBuilder: (context, index) {
                final s = studentProv.students[index];
                return ListTile(
                  title: Text('${s.name} (${s.nis})'),
                  subtitle: Text('${s.kelas} - ${s.jurusan}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(context, student: s)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              studentProv.deleteStudent(s.id)),
                    ],
                  ),
                );
              }),
    );
  }

  void _showForm(BuildContext context, {Student? student}) {
    final nisC = TextEditingController(text: student?.nis);
    final nameC = TextEditingController(text: student?.name);
    final kelasC = TextEditingController(text: student?.kelas);
    final jurusanC = TextEditingController(text: student?.jurusan);
    final studentProv = Provider.of<StudentProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(student == null ? 'Tambah Siswa' : 'Edit Siswa'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nisC, decoration: const InputDecoration(labelText: 'NIS')),
                    TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama')),
                    TextField(controller: kelasC, decoration: const InputDecoration(labelText: 'Kelas')),
                    TextField(controller: jurusanC, decoration: const InputDecoration(labelText: 'Jurusan')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                    onPressed: () async {
                      final s = Student(
                        id: student?.id ?? '',
                        nis: nisC.text,
                        name: nameC.text,
                        kelas: kelasC.text,
                        jurusan: jurusanC.text,
                      );
                      if (student == null) {
                        await studentProv.addStudent(s);
                      } else {
                        await studentProv.updateStudent(s);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan'))
              ],
            ));
  }
}
