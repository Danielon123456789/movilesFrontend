class Service {
  const Service({
    required this.id,
    required this.name,
    required this.duration,
  });

  final String id;
  final String name;
  /// Duración en minutos (persistida en backend).
  final int duration;
}
