class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.daysLabel,
    required this.serviceLabel,
    required this.isActive,
  });

  final String id;
  final String name;
  final String daysLabel;
  final String serviceLabel;
  final bool isActive;
}

