import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/patient.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientController {
  final Dio _dio;
  final _prefix = '/api/v1/patients';

  PatientController(Ref ref) : _dio = ref.read(dioProvider);

  Future<Patient> create({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final response = await _dio.post(
      _prefix,
      data: {'name': name, 'email': email, 'phoneNumber': phoneNumber}
        ..removeWhere((k, v) => v == null),
    );
    return Patient.fromJson(response.data);
  }

  Future<Patient> getById(int id) async {
    final response = await _dio.get('$_prefix/$id');
    return Patient.fromJson(response.data);
  }

  Future<List<Patient>> getByQuery(String query) async {
    final response = await _dio.get(
      _prefix,
      queryParameters: {'query': query},
    );
    return (response.data as List)
        .map((json) => Patient.fromJson(json))
        .toList();
  }
}

final patientControllerProvider = Provider((ref) => PatientController(ref));
