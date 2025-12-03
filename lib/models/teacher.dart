class Teacher {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String phone;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.phone,
  });

  factory Teacher.fromMap(String id, Map<String, dynamic> data) {
    return Teacher(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      subject: data['subject'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'phone': phone,
    };
  }
}
