import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login user dengan email & password dan return UserModel
  Future<UserModel?> login(String email, String password) async {
    try {
      print("🔹 Mencoba login dengan email: $email");

      // 1️⃣ Login ke Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      print("✅ Login FirebaseAuth berhasil");

      if (user == null) {
        print("❌ User tidak ditemukan dari FirebaseAuth");
        return null;
      }

      // 2️⃣ Ambil data user dari Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print("❌ Data user tidak ditemukan di Firestore (users/${user.uid})");
        return null;
      }

      print("✅ Data user ditemukan di Firestore");
      final data = userDoc.data() as Map<String, dynamic>;
      return UserModel(
        id: userDoc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? '',
        linkedId: data['linkedId'],
      );
    } catch (e) {
      print("❌ Error login: $e");
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
