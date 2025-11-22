class Student {
  final String id;
  final String nis;
  final String name;
  final String kelas;
  final String jurusan;

  Student({
    required this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.jurusan,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      nis: data['nis'] ?? '',
      name: data['name'] ?? '',
      kelas: data['kelas'] ?? '',
      jurusan: data['jurusan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nis': nis,
      'name': name,
      'kelas': kelas,
      'jurusan': jurusan,
    };
  }
}
