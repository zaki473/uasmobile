import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPengumumanScreen extends StatefulWidget {
  final String id;
  final String oldTitle;
  final String oldContent;

  const EditPengumumanScreen({
    Key? key,
    required this.id,
    required this.oldTitle,
    required this.oldContent,
  }) : super(key: key);

  @override
  State<EditPengumumanScreen> createState() => _EditPengumumanScreenState();
}

class _EditPengumumanScreenState extends State<EditPengumumanScreen> {
  late TextEditingController titleC;
  late TextEditingController contentC;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.oldTitle);
    contentC = TextEditingController(text: widget.oldContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Pengumuman")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: contentC,
              decoration: const InputDecoration(labelText: "Isi Pengumuman"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Simpan Perubahan"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("pengumuman")
                    .doc(widget.id)
                    .update({
                  "title": titleC.text,
                  "content": contentC.text,
                  "timestamp": FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
