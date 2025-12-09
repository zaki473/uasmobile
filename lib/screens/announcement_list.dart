import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pengumuman.dart';
import 'announcement_edit.dart';

class AnnouncementList extends StatelessWidget {
  final bool showDelete;
  const AnnouncementList({Key? key, required this.showDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("pengumuman")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("Belum ada pengumuman"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(data['title']),
                subtitle: Text(data['content']),
                trailing: showDelete
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPengumumanScreen(
                                    id: data.id,
                                    oldTitle: data['title'],
                                    oldContent: data['content'],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("pengumuman")
                                  .doc(data.id)
                                  .delete();
                            },
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
