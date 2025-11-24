// lib/screens/student_announcement.dart
import 'package:flutter/material.dart';
import 'package:uasmobile/screens/announcement_list.dart';


class StudentAnnouncement extends StatelessWidget {
  const StudentAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengumuman (Siswa)")),
      body: const AnnouncementList(showDelete: false),
    );
  }
}
