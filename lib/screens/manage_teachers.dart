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
    Future.microtask(() =>
        Provider.of<TeacherProvider>(context, listen: false).fetchTeachers());
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TeacherProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kelola Guru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.person_add),
        label: const Text("Tambah Guru"),
      ),
      body: prov.teachers.isEmpty
          ? const Center(child: Text("Belum ada data guru"))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: prov.teachers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = prov.teachers[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: Text(t.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t.subject, style: const TextStyle(color: Colors.green)),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') _showForm(context, teacher: t);
                      if (value == 'delete') _confirmDelete(context, prov, t.id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                              children: [Icon(Icons.edit), SizedBox(width: 10), Text('Edit')])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                              children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text('Hapus', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                );
              }),
    );
  }

  void _confirmDelete(BuildContext context, TeacherProvider prov, String id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Hapus Guru?"),
              content: const Text("Data guru akan dihapus permanen."),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      prov.deleteTeacher(id);
                      Navigator.pop(context);
                    },
                    child: const Text("Hapus"))
              ],
            ));
  }

  void _showForm(BuildContext context, {Teacher? teacher}) {
    final isEditing = teacher != null;
    final nameC = TextEditingController(text: teacher?.name);
    final subjectC = TextEditingController(text: teacher?.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing ? 'Edit Guru' : 'Tambah Guru', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Guru', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: subjectC, decoration: const InputDecoration(labelText: 'Mata Pelajaran', border: OutlineInputBorder())),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final prov = Provider.of<TeacherProvider>(context, listen: false);
                    if (isEditing) {
                      final t = Teacher(id: teacher.id, name: nameC.text, subject: subjectC.text);
                      await prov.updateTeacher(t);
                    } else {
                      final t = Teacher(id: '', name: nameC.text, subject: subjectC.text);
                      await prov.addTeacher(t);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
