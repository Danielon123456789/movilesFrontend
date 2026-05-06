import '../../domain/entities/therapist.dart';

class TherapistModel extends Therapist {
  const TherapistModel({
    required super.id,
    required super.name,
    required super.email,
    required super.specialty,
    required super.initials,
    required super.schedule,
    required this.phoneNumber,
  });

  final String? phoneNumber;

  factory TherapistModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Sin nombre';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
    return TherapistModel(
      id: json['id'].toString(),
      name: name,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      specialty: 'Fisioterapia', // Placeholder for now
      initials: initials,
      schedule: const [
         TherapistSchedule(day: 'Lun', timeRange: '07:00 - 15:00'),
         TherapistSchedule(day: 'Mar', timeRange: '07:00 - 15:00'),
         TherapistSchedule(day: 'Mié', timeRange: '07:00 - 15:00'),
         TherapistSchedule(day: 'Jue', timeRange: '07:00 - 15:00'),
         TherapistSchedule(day: 'Vie', timeRange: '07:00 - 15:00'),
      ], // Placeholder
    );
  }

  TherapistModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? specialty,
    String? initials,
    List<TherapistSchedule>? schedule,
  }) {
    return TherapistModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialty: specialty ?? this.specialty,
      initials: initials ?? this.initials,
      schedule: schedule ?? this.schedule,
    );
  }
}
