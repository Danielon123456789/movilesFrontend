class Service {
  final int id;
  final String name;
  final int duration;

  Service({required this.id, required this.name, required this.duration});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
    );
  }
}
