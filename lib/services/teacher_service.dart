import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';

class TeacherService {
  final CollectionReference teacherRef =
      FirebaseFirestore.instance.collection('teachers');

  // CREATE
  Future<void> addTeacher(Teacher teacher) async {
    await teacherRef.add(teacher.toMap());
  }

  // READ (STREAM)
  Stream<List<Teacher>> getTeachers() {
    return teacherRef.snapshots().map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) => Teacher.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        ).toList();
      },
    );
  }

  // UPDATE
  Future<void> updateTeacher(String id, Teacher teacher) async {
    await teacherRef.doc(id).update(teacher.toMap());
  }

  // DELETE
  Future<void> deleteTeacher(String id) async {
    await teacherRef.doc(id).delete();
  }
}
