import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/appointment.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentController {
  final Dio _dio;
  final _prefix = '/api/v1/appointments';

  AppointmentController(Ref ref) : _dio = ref.read(dioProvider);

  Future<Appointment> create({
    required int patientId,
    required int therapistId,
    required DateTime startDate,
    required DateTime endDate,
    int? serviceId,
    String? notes,
  }) async {
    final response = await _dio.post(
      _prefix,
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
    final response = await _dio.get(
      '$_prefix/therapist/me',
      queryParameters: query.toJson(),
    );
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<Appointment> getById(int id) async {
    final response = await _dio.get('$_prefix/$id');
    return Appointment.fromJson(response.data);
  }

  Future<List<Appointment>> getByQuery(QueryAppointments query) async {
    final response = await _dio.get(
      _prefix,
      queryParameters: query.toJson(),
    );
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<Appointment> updateNotes(int id, String notes) async {
    final response = await _dio.put(
      '$_prefix/$id/notes',
      data: {'notes': notes},
    );
    return Appointment.fromJson(response.data);
  }
}

final appointmentControllerProvider = Provider(
  (ref) => AppointmentController(ref),
);
