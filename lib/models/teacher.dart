class Teacher {
  final String id;
  final String name;
  final String subject;

  Teacher({required this.id, required this.name, required this.subject});

  factory Teacher.fromMap(String id, Map<String, dynamic> data) {
    return Teacher(
      id: id,
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subject': subject,
    };
  }
}
