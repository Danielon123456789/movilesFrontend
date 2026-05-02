// ignore_for_file: use_null_aware_elements

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

class BackendApi {
  BackendApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/api/v1/users/me');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? query,
    String? role,
  }) async {
    final res = await _dio.get(
      '/api/v1/users',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (role != null && role.isNotEmpty) 'role': role,
      },
    );
    return (res.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final res = await _dio.get('/api/v1/users/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createOrganization(String name) async {
    final res = await _dio.post('/api/v1/organizations', data: {'name': name});
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getMyOrganization() async {
    final res = await _dio.get('/api/v1/organizations/mine');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateUserRole({
    required String email,
    required String role,
  }) async {
    final res = await _dio.put(
      '/api/v1/organizations/role',
      data: {'email': email, 'role': role},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getPatients({String? query}) async {
    final res = await _dio.get(
      '/api/v1/patients',
      queryParameters: {if (query != null && query.isNotEmpty) 'query': query},
    );
    return (res.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getPatientById(int id) async {
    final res = await _dio.get('/api/v1/patients/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/v1/patients', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    final res = await _dio.get('/api/v1/services');
    return (res.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createService({
    required String name,
    required int duration,
  }) async {
    final res = await _dio.post(
      '/api/v1/services',
      data: {'name': name, 'duration': duration},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getAppointments({
    int? patientId,
    int? therapistId,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) async {
    final res = await _dio.get(
      '/api/v1/appointments',
      queryParameters: {
        if (patientId != null) 'patientId': patientId,
        if (therapistId != null) 'therapistId': therapistId,
        if (rangeStart != null) 'rangeStart': rangeStart.toIso8601String(),
        if (rangeEnd != null) 'rangeEnd': rangeEnd.toIso8601String(),
      },
    );
    return (res.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getMyTherapistAppointments({
    int? patientId,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) async {
    final res = await _dio.get(
      '/api/v1/appointments/therapist/me',
      queryParameters: {
        if (patientId != null) 'patientId': patientId,
        if (rangeStart != null) 'rangeStart': rangeStart.toIso8601String(),
        if (rangeEnd != null) 'rangeEnd': rangeEnd.toIso8601String(),
      },
    );
    return (res.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getAppointmentById(int id) async {
    final res = await _dio.get('/api/v1/appointments/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.post('/api/v1/appointments', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateAppointmentNotes({
    required int id,
    required String notes,
  }) async {
    final res = await _dio.put(
      '/api/v1/appointments/$id/notes',
      data: {'notes': notes},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}

final backendApiProvider = Provider<BackendApi>((ref) {
  return BackendApi(DioClient.create(ref));
});
