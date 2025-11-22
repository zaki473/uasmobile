import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';

class InputGrade extends StatefulWidget {
  const InputGrade({super.key});

  @override
  State<InputGrade> createState() => _InputGradeState();
}

class _InputGradeState extends State<InputGrade> {
  final studentIdC = TextEditingController();
  final subjectC = TextEditingController();
  final tugasC = TextEditingController();
  final utsC = TextEditingController();
  final uasC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gradeProv = Provider.of<GradeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: studentIdC, decoration: const InputDecoration(labelText: 'ID Siswa')),
          TextField(controller: subjectC, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
          TextField(controller: tugasC, decoration: const InputDecoration(labelText: 'Nilai Tugas'), keyboardType: TextInputType.number),
          TextField(controller: utsC, decoration: const InputDecoration(labelText: 'Nilai UTS'), keyboardType: TextInputType.number),
          TextField(controller: uasC, decoration: const InputDecoration(labelText: 'Nilai UAS'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                await gradeProv.addGrade(
                  studentId: studentIdC.text,
                  subject: subjectC.text,
                  tugas: double.parse(tugasC.text),
                  uts: double.parse(utsC.text),
                  uas: double.parse(uasC.text),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Nilai disimpan')));
              },
              child: const Text('Simpan Nilai')),
        ]),
      ),
    );
  }
}
