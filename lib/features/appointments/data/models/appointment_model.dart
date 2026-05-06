/// Subconjunto de `PatientDto` en respuestas de cita (no reutilizar [PatientModel]).
class AppointmentPatientSnapshot {
  const AppointmentPatientSnapshot({
    required this.id,
    this.name,
  });

  final int id;
  final String? name;

  factory AppointmentPatientSnapshot.fromJson(Map<String, dynamic> json) {
    return AppointmentPatientSnapshot(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
    );
  }
}

/// Subconjunto de `UserDto` (terapeuta) en respuestas de cita.
class AppointmentTherapistSnapshot {
  const AppointmentTherapistSnapshot({
    required this.id,
    this.name,
  });

  final int id;
  final String? name;

  factory AppointmentTherapistSnapshot.fromJson(Map<String, dynamic> json) {
    return AppointmentTherapistSnapshot(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
    );
  }
}

class AppointmentServiceSnapshot {
  const AppointmentServiceSnapshot({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory AppointmentServiceSnapshot.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceSnapshot(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }
}

/// `AppointmentDto` del backend.
class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.patient,
    required this.therapist,
    this.service,
  });

  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final AppointmentPatientSnapshot patient;
  final AppointmentTherapistSnapshot therapist;
  final AppointmentServiceSnapshot? service;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'];
    return AppointmentModel(
      id: (json['id'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      notes: json['notes'] as String,
      patient: AppointmentPatientSnapshot.fromJson(
        Map<String, dynamic>.from(json['patient'] as Map),
      ),
      therapist: AppointmentTherapistSnapshot.fromJson(
        Map<String, dynamic>.from(json['therapist'] as Map),
      ),
      service: serviceJson is Map
          ? AppointmentServiceSnapshot.fromJson(
              Map<String, dynamic>.from(serviceJson),
            )
          : null,
    );
  }
}
