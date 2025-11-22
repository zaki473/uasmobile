import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Student> _students = [];
  List<Student> get students => _students;

  // --- 1. FETCH DATA (Ambil dari 'users' yang role-nya 'siswa') ---
  Future<void> fetchStudents() async {
    try {
      // PERBAIKAN: Ambil dari collection 'users' dimana role = 'siswa'
      final snapshot = await _db.collection('users')
          .where('role', isEqualTo: 'siswa') 
          .get();
      
      _students = snapshot.docs.map((d) {
        final data = d.data();
        return Student(
          id: d.id, // Ini UID Auth
          nis: data['nis'] ?? data['linkedId'] ?? '-', 
          name: data['name'] ?? 'Tanpa Nama',
          kelas: data['kelas'] ?? '-', 
          jurusan: data['jurusan'] ?? '-',
        );
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch students error: $e');
    }
  }

  // --- 2. ADD STUDENT WITH AUTH (Simpan ke 'users') ---
  Future<void> addStudentWithAuth({
    required String email,
    required String password,
    required String nis,
    required String name,
    required String kelas,
    required String jurusan,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // Trik agar Admin tidak logout
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      final authInstance = FirebaseAuth.instanceFor(app: secondaryApp);

      // A. Buat Akun Auth
      UserCredential uc = await authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String newUid = uc.user!.uid; 

      // B. PERBAIKAN: Simpan ke 'users'
      await _db.collection('users').doc(newUid).set({
        'uid': newUid,
        'name': name,
        'email': email,
        'role': 'siswa', // PENTING: Role diset 'siswa' agar muncul di dropdown guru
        'nis': nis,
        'linkedId': nis, 
        'kelas': kelas,
        'jurusan': jurusan,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // C. Update List Lokal
      final newStudent = Student(
        id: newUid,
        nis: nis,
        name: name,
        kelas: kelas,
        jurusan: jurusan,
      );
      
      _students.add(newStudent);
      notifyListeners();

    } catch (e) {
      debugPrint('Register student error: $e');
      rethrow; 
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  // --- 3. UPDATE STUDENT (Target 'users') ---
  Future<void> updateStudent(Student s) async {
    try {
      await _db.collection('users').doc(s.id).update({
        'name': s.name,
        'nis': s.nis,
        'linkedId': s.nis,
        'kelas': s.kelas,
        'jurusan': s.jurusan,
      });
      
      final index = _students.indexWhere((element) => element.id == s.id);
      if (index != -1) {
        _students[index] = s;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update student error: $e');
      rethrow;
    }
  }

  // --- 4. DELETE STUDENT ---
  Future<void> deleteStudent(String id) async {
    try {
      await _db.collection('users').doc(id).delete();
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete student error: $e');
    }
  }
}