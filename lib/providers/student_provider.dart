import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Student> _students = [];

  List<Student> get students => _students;

  Future<void> fetchStudents() async {
    try {
      final snapshot = await _db.collection('students').get();
      _students = snapshot.docs.map((d) => Student.fromMap(d.id, d.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch students error: $e');
    }
  }

  Future<void> addStudent(Student s) async {
    try {
      await _db.collection('students').add(s.toMap());
      await fetchStudents();
    } catch (e) {
      debugPrint('Add student error: $e');
    }
  }

  Future<void> updateStudent(Student s) async {
    try {
      await _db.collection('students').doc(s.id).update(s.toMap());
      await fetchStudents();
    } catch (e) {
      debugPrint('Update student error: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _db.collection('students').doc(id).delete();
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete student error: $e');
    }
  }
}
