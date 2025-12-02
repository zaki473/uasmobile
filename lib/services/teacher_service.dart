import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';

class TeacherService {
final CollectionReference ref = FirebaseFirestore.instance.collection('teachers');

// CREATE
Future<void> addTeacher(Teacher t) async {
await ref.doc(t.id).set(t.toMap());
}

// UPDATE
Future<void> updateTeacher(Teacher t) async {
await ref.doc(t.id).update(t.toMap());
}

// DELETE
Future<void> deleteTeacher(String id) async {
await ref.doc(id).delete();
}

// READ STREAM
Stream<List<Teacher>> getTeachers() {
return ref.snapshots().map((snapshot) {
return snapshot.docs.map((doc) {
final data = doc.data() as Map<String, dynamic>;
return Teacher.fromMap(doc.id, data);
}).toList();
});
}
}