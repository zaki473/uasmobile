// lib/screens/teacher_announcement.dart
import 'package:flutter/material.dart';
import 'package:uasmobile/screens/announcement_list.dart';


class TeacherAnnouncement extends StatelessWidget {
  const TeacherAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengumuman (Guru)")),
      body: const AnnouncementList(showDelete: false),
    );
  }
}
