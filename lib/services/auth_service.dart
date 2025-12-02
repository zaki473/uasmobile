import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/teacher.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN (cek di collection users)
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Jika belum ada, buat default user student
        String defaultName = email.split('@')[0];
        Map<String, dynamic> newData = {
          'uid': user.uid,
          'name': defaultName,
          'email': email,
          'role': 'student',
          'linkedId': '-',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(newData);
        return UserModel(
          uid: user.uid,
          name: defaultName,
          email: email,
          role: 'student',
          linkedId: '-',
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      return UserModel(
        uid: data['uid'] ?? user.uid,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'student',
        linkedId: data['linkedId'],
      );
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // REGISTER USER (Admin menambah akun biasa atau guru)
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? linkedId,
  }) async {
    FirebaseApp? secondaryApp;

    try {
      // app kedua supaya admin tetap login
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryRegisterApp',
        options: Firebase.app().options,
      );
      final auth2 = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential uc = await auth2.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = uc.user!.uid;

      // simpan data ke collection users
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'linkedId': linkedId ?? '-',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      try {
        if (secondaryApp != null) await secondaryApp.delete();
      } catch (deleteError) {
        // Abaikan error saat hapus secondary app (bisa terjadi di web)
        debugPrint('Error deleting secondary app: $deleteError');
      }
    }
  }

  // REGISTER TEACHER (buat akun guru + entry di users dan teachers)
  Future<String?> registerTeacher({
    required String email,
    required String password,
    required String name,
    required String subject,
    required String phone,
  }) async {
    // Buat entry di users dulu
    String? err = await registerUser(
      email: email,
      password: password,
      name: name,
      role: 'guru',
    );
    if (err != null) return err;

    try {
      // Ambil UID user yang baru dibuat
      QuerySnapshot q = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (q.docs.isEmpty) return "UID guru tidak ditemukan.";

      String uid = q.docs.first['uid'];

      // Simpan detail ke collection teachers
      Teacher teacher = Teacher(
        id: uid,
        name: name,
        subject: subject,
        email: email,
        phone: phone,
      );
      await _firestore.collection('teachers').doc(uid).set(teacher.toMap());

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
