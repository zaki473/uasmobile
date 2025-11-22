class Grade {
  final String id;
  final String studentId;
  final String subject;
  final double tugas;
  final double uts;
  final double uas;
  final double finalScore;
  final String predicate;

  Grade({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.tugas,
    required this.uts,
    required this.uas,
    required this.finalScore,
    required this.predicate,
  });

  /// Factory untuk membuat grade dari input nilai mentah
  factory Grade.fromInput({
    required String id,
    required String studentId,
    required String subject,
    required double tugas,
    required double uts,
    required double uas,
  }) {
    final finalScore = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);
    final predicate = _getPredicate(finalScore);

    return Grade(
      id: id,
      studentId: studentId,
      subject: subject,
      tugas: tugas,
      uts: uts,
      uas: uas,
      finalScore: finalScore,
      predicate: predicate,
    );
  }

  /// Konversi nilai ke huruf
  static String _getPredicate(double score) {
    if (score >= 85) return 'A';
    if (score >= 75) return 'B';
    if (score >= 65) return 'C';
    return 'D';
  }

  factory Grade.fromMap(String id, Map<String, dynamic> data) {
    return Grade(
      id: id,
      studentId: data['studentId'] ?? '',
      subject: data['subject'] ?? '',
      tugas: (data['tugas'] ?? 0).toDouble(),
      uts: (data['uts'] ?? 0).toDouble(),
      uas: (data['uas'] ?? 0).toDouble(),
      finalScore: (data['finalScore'] ?? 0).toDouble(),
      predicate: data['predicate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subject': subject,
      'tugas': tugas,
      'uts': uts,
      'uas': uas,
      'finalScore': finalScore,
      'predicate': predicate,
    };
  }
}
