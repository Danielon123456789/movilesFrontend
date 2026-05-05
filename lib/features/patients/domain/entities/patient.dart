class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.daysLabel,
    required this.serviceLabel,
    required this.isActive,
    this.email,
    this.phoneNumber,
  });

  final String id;
  final String name;
  final String daysLabel;
  final String serviceLabel;
  final bool isActive;
  final String? email;
  final String? phoneNumber;

  Patient copyWith({
    String? id,
    String? name,
    String? daysLabel,
    String? serviceLabel,
    bool? isActive,
    String? email,
    String? phoneNumber,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      daysLabel: daysLabel ?? this.daysLabel,
      serviceLabel: serviceLabel ?? this.serviceLabel,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

