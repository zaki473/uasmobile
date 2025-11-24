import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPengumumanScreen extends StatefulWidget {
  const AddPengumumanScreen({Key? key}) : super(key: key);

  @override
  _AddPengumumanScreenState createState() => _AddPengumumanScreenState();
}

class _AddPengumumanScreenState extends State<AddPengumumanScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Pengumuman")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul Pengumuman",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Isi Pengumuman",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                final judul = titleController.text.trim();
                final isi = contentController.text.trim();

                if (judul.isEmpty || isi.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field harus diisi")),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('pengumuman')
                    .add({
                  'judul': judul,
                  'isi': isi,
                  'tanggal': Timestamp.now(),
                });

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
