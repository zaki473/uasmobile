class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? linkedId; // <-- tambahkan ini, nullable

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.linkedId, // <-- optional
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      linkedId: map['linkedId'], // <-- ambil dari Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'linkedId': linkedId ?? '-', // <-- simpan default jika null
    };
  }
}
