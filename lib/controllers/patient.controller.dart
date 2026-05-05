import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/patient.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientController {
  final Ref _ref;

  PatientController(this._ref);

  Future<Patient> create({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post(
      '/patients',
      data: {'name': name, 'email': email, 'phoneNumber': phoneNumber}
        ..removeWhere((k, v) => v == null),
    );
    return Patient.fromJson(response.data);
  }

  Future<Patient> getById(int id) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/patients/$id');
    return Patient.fromJson(response.data);
  }

  Future<List<Patient>> getByQuery(String query) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      '/patients',
      queryParameters: {'query': query},
    );
    return (response.data as List)
        .map((json) => Patient.fromJson(json))
        .toList();
  }
}

final patientControllerProvider = Provider((ref) => PatientController(ref));
