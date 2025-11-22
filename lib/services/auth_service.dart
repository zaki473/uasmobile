import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; 
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login user.
  /// FITUR PINTAR: Jika data di database tidak ditemukan, 
  /// sistem akan otomatis membuatnya agar user tetap bisa masuk.
  Future<UserModel?> login(String email, String password) async {
    try {
      print("🔹 Mencoba login dengan email: $email");

      // 1️⃣ Login ke Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user == null) {
        print("❌ User tidak ditemukan dari FirebaseAuth");
        return null;
      }

      print("✅ Login FirebaseAuth berhasil (UID: ${user.uid})");

      // 2️⃣ Cek data user dari Firestore
      DocumentReference docRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await docRef.get();

      // 3️⃣ LOGIKA AUTO-GENERATE (Solusi Error Data Hilang)
      if (!userDoc.exists) {
        print("⚠️ Data Firestore KOSONG! Membuat data default otomatis...");
        
        // Ambil nama dari email (misal: admin@sekolah.com -> admin)
        String defaultName = email.split('@')[0];
        
        // Default data
        Map<String, dynamic> newData = {
          'uid': user.uid,
          'name': defaultName,
          'email': email,
          'role': 'student', // Default role aman (nanti bisa diubah admin)
          'linkedId': '-',
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Simpan ke database
        await docRef.set(newData);
        print("✅ Data default berhasil dibuat!");

        // Return user model baru
        return UserModel(
          id: user.uid,
          name: defaultName,
          email: email,
          role: 'student',
          linkedId: '-',
        );
      }

      // 4️⃣ Jika data sudah ada, ambil seperti biasa
      print("✅ Data user ditemukan di Firestore");
      final data = userDoc.data() as Map<String, dynamic>;
      
      return UserModel(
        id: userDoc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'student',
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

  /// 🆕 REGISTER USER (Untuk Admin)
  /// Membuat User Auth + Database User sekaligus tanpa logout Admin.
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String role, // 'admin' atau 'student'
    String? linkedId,     // Opsional: NISN atau Kode Guru
  }) async {
    FirebaseApp? secondaryApp;
    
    try {
      print("🔹 Admin mencoba mendaftarkan user baru: $email ($role)");

      // 1. Inisialisasi App Sekunder (Agar Admin tidak logout)
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryRegisterApp',
        options: Firebase.app().options,
      );

      final authInstance = FirebaseAuth.instanceFor(app: secondaryApp);

      // 2. Buat Akun di Authentication
      UserCredential uc = await authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String newUid = uc.user!.uid;
      print("✅ Akun Auth berhasil dibuat. UID: $newUid");

      // 3. Simpan Data ke Firestore (ID Dokumen = UID Auth)
      await _firestore.collection('users').doc(newUid).set({
        'uid': newUid,
        'name': name,
        'email': email,
        'role': role,
        'linkedId': linkedId ?? '-',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Data Firestore berhasil disimpan untuk $name");
      return null; // Return null artinya SUKSES

    } catch (e) {
      print("❌ Gagal register: $e");
      return e.toString(); // Return pesan error
    } finally {
      // Hapus app sekunder untuk hemat memori
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}