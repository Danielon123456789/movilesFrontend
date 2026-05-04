class User {
  final int id;
  final String email;
  final String role;
  final String? name;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }
}

class Role {
  static final admin = 'admin';
  static final secretary = 'secretary';
  static final therapist = 'therapist';
  static final none = 'none';
}
