/// Respuesta JSON del backend (`ServiceDto`).
class ServiceModel {
  ServiceModel({
    required this.id,
    required this.name,
    required this.duration,
  });

  final int id;
  final String name;
  final int duration;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
    );
  }
}
