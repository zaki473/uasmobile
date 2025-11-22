import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tambah data ke koleksi
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  /// Update data berdasarkan ID
  Future<void> updateData(
      String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  /// Hapus data berdasarkan ID
  Future<void> deleteData(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  /// Ambil semua data dalam koleksi
  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Ambil data berdasarkan kondisi tertentu
  Future<List<Map<String, dynamic>>> getWhere(
      String collection, String field, dynamic value) async {
    final snapshot =
        await _db.collection(collection).where(field, isEqualTo: value).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
