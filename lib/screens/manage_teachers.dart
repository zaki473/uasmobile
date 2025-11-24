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

    // 1. Deteksi Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. Tentukan Warna
    final bgColor = isDark ? null : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor, // <-- Dinamis
      appBar: AppBar(
        title: Text(
          'Kelola Guru', 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor), // <-- Icon back dinamis
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text("Tambah Guru"),
      ),
      body: prov.teachers.isEmpty
          ? Center(
              child: Text(
                "Belum ada data guru", 
                style: TextStyle(color: isDark ? Colors.grey : Colors.black54)
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: prov.teachers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = prov.teachers[index];
                return ListTile(
                  // Warna kartu dinamis
                  tileColor: cardColor, 
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: Text(
                      t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    t.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: textColor // <-- Nama guru dinamis
                    )
                  ),
                  subtitle: Text(
                    t.subject, 
                    style: TextStyle(
                      // Warna subtitle disesuaikan agar kontras
                      color: isDark ? Colors.greenAccent : Colors.green
                    )
                  ),
                  trailing: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: iconColor),
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') _showForm(context, teacher: t);
                      if (value == 'delete') _confirmDelete(context, prov, t.id);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'edit',
                          child: Row(
                              children: [
                                Icon(Icons.edit, color: textColor), 
                                const SizedBox(width: 10), 
                                Text('Edit', style: TextStyle(color: textColor))
                              ]
                          )
                      ),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red), 
                                SizedBox(width: 10), 
                                Text('Hapus', style: TextStyle(color: Colors.red))
                              ]
                          )
                      ),
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
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Batal")
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
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

    // Variabel warna untuk modal
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    // Warna background textfield
    final inputFillColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]; 

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: sheetColor, // <-- Background modal dinamis
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400], borderRadius: BorderRadius.circular(10)
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Edit Guru' : 'Tambah Guru', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)
              ),
              const SizedBox(height: 20),
              
              // Input Nama
              TextField(
                controller: nameC,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Nama Guru',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person, color: Colors.green),
                ),
              ),
              const SizedBox(height: 12),
              
              // Input Mapel
              TextField(
                controller: subjectC,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Mata Pelajaran',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.book, color: Colors.green),
                ),
              ),
              
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
                      // ID kosong karena biasanya dihandle backend/firebase
                      final t = Teacher(id: '', name: nameC.text, subject: subjectC.text);
                      await prov.addTeacher(t);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}