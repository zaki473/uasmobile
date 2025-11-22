import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewSchedulePage extends StatelessWidget {
  final String uidGuru = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jadwal Mengajar")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jadwal_pelajaran')
            .where('guruId', isEqualTo: uidGuru)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Belum ada jadwal"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    data['mapel'] ?? "-",
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    "${data['hari'] ?? '-'}\n"
                    "${data['jam_mulai'] ?? '-'} - ${data['jam_selesai'] ?? '-'}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
