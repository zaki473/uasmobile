import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementList extends StatelessWidget {
  final bool showDelete;

  const AnnouncementList({Key? key, required this.showDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
          .orderBy('tanggal', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada pengumuman."));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  data['judul'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['isi'] ?? ''),
                trailing: showDelete
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('pengumuman')
                              .doc(doc.id)
                              .delete();
                        },
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
