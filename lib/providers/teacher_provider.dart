import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../services/teacher_service.dart';
import '../services/auth_service.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherService service = TeacherService();

  List<Teacher> teachers = [];

  void fetchTeachers() {
    service.getTeachers().listen((data) {
      teachers = data;
      notifyListeners();
    });
  }

  Future<void> addTeacher(Teacher t) async {
    await service.addTeacher(t);
  }

  /// Tambah guru sekaligus membuat akun (email/password) seperti flow siswa.
  /// Mengembalikan `null` jika sukses, atau pesan error jika gagal.
  Future<String?> addTeacherWithAuth({
    required String email,
    required String password,
    required String name,
    required String subject,
    required String phone,
  }) async {
    final auth = AuthService();
    final err = await auth.registerTeacher(
      email: email,
      password: password,
      name: name,
      subject: subject,
      phone: phone,
    );

    if (err == null) {
      // refresh list
      fetchTeachers();
    }

    return err;
  }

  Future<void> updateTeacher(Teacher t) async {
    await service.updateTeacher(t);
  }

  Future<void> deleteTeacher(String id) async {
    await service.deleteTeacher(id);
  }
}
