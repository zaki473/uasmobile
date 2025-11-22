class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? linkedId; // tambahkan ini

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.linkedId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      linkedId: map['linkedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'linkedId': linkedId,
    };
  }
}
