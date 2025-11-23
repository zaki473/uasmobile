import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade.dart';

class GradeProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Grade> _grades = [];
  bool _isLoading = false;

  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading;

  Future<void> fetchGrades(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final snapshot = await _db
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .get();
      _grades = snapshot.docs.map((d) {
        final data = d.data();
        return Grade.fromMap(d.id, data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Fetch grades error: $e');
    }
  }

  Future<void> addGrade({
    required String studentId,
    required String subject,
    required double tugas,
    required double uts,
    required double uas,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final grade = Grade.fromInput(
        id: '',
        studentId: studentId,
        subject: subject,
        tugas: tugas,
        uts: uts,
        uas: uas,
      );

      await _db.collection('grades').add(grade.toMap());
      // Refresh data setelah menambah
      await fetchGrades(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Add grade error: $e');
    }
  }

  // --- BAGIAN YANG DIPERBAIKI ---
  // Hapus parameter studentId, hitung langsung dari _grades
  double getAverage() {
    if (_grades.isEmpty) return 0;
    
    // Menjumlahkan finalScore dari semua data yang ada di list
    final total = _grades.fold(0.0, (sum, g) => sum + g.finalScore);
    
    return total / _grades.length;
  }
}