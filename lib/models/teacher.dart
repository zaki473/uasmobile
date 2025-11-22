class Teacher {
  final String id;
  final String nip;
  final String name;
  final String subject;

  Teacher({
    required this.id,
    required this.nip,
    required this.name,
    required this.subject,
  });

  factory Teacher.fromMap(String id, Map<String, dynamic> data) {
    return Teacher(
      id: id,
      nip: data['nip'] ?? '',
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nip': nip,
      'name': name,
      'subject': subject,
    };
  }
}
