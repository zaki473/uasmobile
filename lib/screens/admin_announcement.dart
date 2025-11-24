import 'package:flutter/material.dart';
import 'package:uasmobile/screens/announcement_list.dart';
import 'package:uasmobile/screens/pengumuman.dart';

class AdminAnnouncement extends StatelessWidget {
  const AdminAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengumuman (Admin)"),
      ),

      // LIST PENGUMUMAN UNTUK ADMIN (boleh hapus)
      body: const AnnouncementList(showDelete: true),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // buka halaman tambah pengumuman
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPengumumanScreen()),
          );
        },
      ),
    );
  }
}
