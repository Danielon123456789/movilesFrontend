import 'package:agenda/models/patient.model.dart';
import 'package:agenda/models/service.model.dart';
import 'package:agenda/models/user.model.dart';

class Appointment {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final Patient patient;
  final User therapist;
  final Service? service;

  Appointment({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.patient,
    required this.therapist,
    this.service,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      notes: json['notes'],
      patient: Patient.fromJson(json['patient']),
      therapist: User.fromJson(json['therapist']),
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : null,
    );
  }
}

class QueryAppointments {
  final int? patientId;
  final int? therapistId;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  QueryAppointments({
    this.patientId,
    this.therapistId,
    this.rangeStart,
    this.rangeEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'therapistId': therapistId,
      'rangeStart': rangeStart?.toIso8601String(),
      'rangeEnd': rangeEnd?.toIso8601String(),
    };
  }
}
