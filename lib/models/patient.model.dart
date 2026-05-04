class Patient {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;

  Patient({required this.id, required this.name, this.email, this.phoneNumber});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
