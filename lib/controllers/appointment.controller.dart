import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/appointment.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentController {
  final Ref _ref;

  AppointmentController(this._ref);

  Future<Appointment> create({
    required int patientId,
    required int therapistId,
    required DateTime startDate,
    required DateTime endDate,
    int? serviceId,
    String? notes,
  }) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post(
      '/appointments',
      data: {
        'patientId': patientId,
        'therapistId': therapistId,
        'startDate': startDate,
        'endDate': endDate,
        'serviceId': serviceId,
        'notes': notes,
      }..removeWhere((k, v) => v == null),
    );
    return Appointment.fromJson(response.data);
  }

  Future<List<Appointment>> getMyAppointments(QueryAppointments query) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      '/appointments/therapist/me',
      queryParameters: query.toJson(),
    );
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<Appointment> getById(int id) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/appointments/$id');
    return Appointment.fromJson(response.data);
  }

  Future<List<Appointment>> getByQuery(QueryAppointments query) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      '/appointments',
      queryParameters: query.toJson(),
    );
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<Appointment> updateNotes(int id, String notes) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.put(
      '/appointments/$id/notes',
      data: {'notes': notes},
    );
    return Appointment.fromJson(response.data);
  }
}

final appointmentControllerProvider = Provider(
  (ref) => AppointmentController(ref),
);
