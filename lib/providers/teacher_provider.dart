import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';

class TeacherProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Teacher> _teachers = [];
  List<Teacher> get teachers => _teachers;

  // --- FETCH DATA ---
  Future<void> fetchTeachers() async {
    try {
      final snapshot = await _db.collection('teachers').get();
      _teachers = snapshot.docs.map((d) {
        final data = d.data();
        return Teacher(
          id: d.id,
          name: data['name'] ?? 'Tanpa Nama',
          subject: data['subject'] ?? '-',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch teachers error: $e');
    }
  }

  // --- ADD TEACHER ---
  Future<void> addTeacher(Teacher t) async {
    try {
      await _db.collection('teachers').add(t.toMap());
      await fetchTeachers();
    } catch (e) {
      debugPrint('Add teacher error: $e');
    }
  }

  // --- UPDATE TEACHER ---
  Future<void> updateTeacher(Teacher t) async {
    try {
      await _db.collection('teachers').doc(t.id).update(t.toMap());
      await fetchTeachers();
    } catch (e) {
      debugPrint('Update teacher error: $e');
    }
  }

  // --- DELETE TEACHER ---
  Future<void> deleteTeacher(String id) async {
    try {
      await _db.collection('teachers').doc(id).delete();
      _teachers.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete teacher error: $e');
    }
  }
}
